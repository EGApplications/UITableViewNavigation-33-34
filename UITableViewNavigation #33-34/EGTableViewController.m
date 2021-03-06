//
//  EGTableViewController.m
//  UITableViewNavigation #33-34
//
//  Created by Евгений Глухов on 01.07.15.
//  Copyright (c) 2015 EGApps. All rights reserved.
//

#import "EGTableViewController.h"
#import "EGFolderCell.h"
#import "EGFileCell.h"

@interface EGTableViewController ()

@property (strong, nonatomic) NSMutableArray* files;  // Массив для файлов
@property (strong, nonatomic) NSMutableArray* directories; // Массив для папок (сортировка)

@property (assign, nonatomic) unsigned long long currentFolderSize;

@end

@implementation EGTableViewController

- (id) initWithFolderPath:(NSString*) path { // Метод инициализации UITableViewController c навигацией
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        
        self.path = path;
        
    }
    
    return self;
    
}

- (void) setPath:(NSString *) path { // если self.path, то вызывается этот метод

    _path = path; // во внутреннюю переменную кладем путь, с которым проинициализировался self.path
    
    NSError* error = nil;
    
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error]; // массив self.contents содержит контент директории по соответствующему пути (path) - файлы и папки
    
    if (error) {
        
        NSLog(@"%@", [error localizedDescription]); // Если где-то что-то не так проинициализировалось, нам выведут ошибку.
        
    }

    [self.tableView reloadData]; // Перезагружаем tableView, чтобы отобразилось содержимое корневой директории
    
    self.navigationItem.title = [self.path lastPathComponent]; // Заголовок - название после последнего слеша
    
}

- (BOOL) isDirectoryAtIndexPath:(NSIndexPath*) indexPath { // Метод возвращает YES, если директория по indexPath, иначе NO.
    
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    
    NSString* filePath = [self.path stringByAppendingPathComponent:fileName];
    
    BOOL isDirectory = NO;
    
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory]; // Проверяем, является ли путь вместе с filePath директорией
    
    return isDirectory;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tempFolderContents = [NSMutableArray array]; // инициализируем временный массив, который будем использовать в методе подсчета размера папки
    
    if (!self.path) {
        
        self.path = @"/Users/Evgen/Documents/EG Apps/HomeWork";
        
    }
    
    self.navigationItem.title = [self.path lastPathComponent];
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(editAction:)];
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addAction:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:editButton, addButton, nil];
    // добавляем наверх сразу две кнопки: редактирование файлов и папок, и их добавление
 
    [self hideSecretFiles]; // Метод прячет скрытые файлы типа .DS_Store
    
}

- (void) viewWillAppear:(BOOL)animated { // Делаем здесь раздельные массивы файлов и папок, чтобы их отсортировать
    
    // self.contents всегда меняется!!! В нем лежит контент текущей директории, в которой находимся
    
    [super viewWillAppear:animated];
    
    // алфавитное расположение файлов и папок
    [self alphabetOrderOfDirectoriesAndFiles];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) hideSecretFiles { // Метод не показывает скрытые файлы
    
    for (NSString* string in self.contents) {
        
        NSString* firstSymbol = [string substringToIndex:1];
        
        if ([firstSymbol containsString:@"."]) {
            
            NSMutableArray* tempArray = [NSMutableArray arrayWithArray:self.contents];
            
            [tempArray removeObject:string];
            
            self.contents = tempArray;
            
        }
        
    }
    
}

- (NSString*) fileSizeFromValue:(unsigned long long) size {
    
    static NSString* units[] = {@"B", @"KB", @"MB", @"GB", @"TB"};
    static int unitsCount = 5;
    
    int index = 0;
    
    double fileSize = (double)size;
    
    while (fileSize > 1024 && index < unitsCount) {
        
        fileSize = fileSize / 1024;
        
        index++;
        
    }
    
    return [NSString stringWithFormat:@"%.2f %@", fileSize, units[index]];
    
}

- (NSString*) folderSizeToCount:(NSMutableArray*) foldersArray { // Метод рекурсивно считает размер папки!
    // В метод передаем массив путей, по которым лежат папки.
    
    // РЕКУРСИЯ ЖИВЕТ ЗДЕСЬ!!!
    
    NSString* result;
    
    NSMutableArray* tempFoldersArray = [NSMutableArray array]; // временный массив
    
    if ([foldersArray count] > 0) { // Если есть директории, ищем файлы
    
        for (NSString* path in foldersArray) {
            
            self.tempFolderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
            // В зависимости от того, сколько у нас директорий, у каждой считываем контент
            
            for (int i = 0; i < [self.tempFolderContents count]; i++) {
                // Пробегаемся по контенту определенного пути, чтобы понять, где файлы, а где директории и, соответственно, их добавляем в массив для следующего прогона по методу
                
                NSString* objectName = [self.tempFolderContents objectAtIndex:i];
                
                NSString* objectPath = [path stringByAppendingPathComponent:objectName];
                
                BOOL isDirectory = NO;
                
                [[NSFileManager defaultManager] fileExistsAtPath:objectPath isDirectory:&isDirectory];
                
                if (isDirectory) {
                    
                    // Если директория, кладем путь до нее в массив
                    [tempFoldersArray addObject:objectPath];
                    
                } else {
                    // Если файл, считаем его размер и суммируем с предыдущими посчитанными.
                    
                    NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:objectPath error:nil];
                    
                    self.currentFolderSize = self.currentFolderSize + [attributes fileSize];
                    
                }
                
            }
            
        }
        
        // После того, как прошли по всем папкам, очищаем массив, а новые, найденные директории, на уровень глубже, добавляем в очищенный массив.
        [foldersArray removeAllObjects];
        
        foldersArray = tempFoldersArray;
        
        return [self folderSizeToCount:foldersArray]; // РЕКУРСИЯ
        
    } else {
        // Смотрим файлы по директориям, пока директорий не станет 0, тогда все посчитанные файлы считаем
        
        result = [self fileSizeFromValue:self.currentFolderSize];
        
        return result;
        
    }

    return nil;
    
}

- (void) alphabetOrderOfDirectoriesAndFiles { // Метод сортировки файлов и папок (Сверху папки, снизу файлы)
    
    self.files = [NSMutableArray array];
    self.directories = [NSMutableArray array];
    
    for (int i = 0; i < [self.contents count]; i++) {
        
        NSString* object = [self.contents objectAtIndex:i];
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        if ([self isDirectoryAtIndexPath:indexPath]) {
            
            [self.directories addObject:object];
            
        } else {
            
            [self.files addObject:object];
            
        }
        
    }
    
    self.directories = (NSMutableArray*)[self.directories sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.files = (NSMutableArray*)[self.files sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    self.contents = [NSArray arrayWithArray:self.directories]; // сначала папки по порядку
    
    self.contents = [self.contents arrayByAddingObjectsFromArray:self.files]; // потом файлы
    
}

#pragma mark - Actions

- (void) editAction:(UIBarButtonItem*) sender { // Метод для Edit/Done кнопки при нажатии
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if (self.tableView.isEditing) {
        
        UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(editAction:)];
        
        self.navigationItem.rightBarButtonItem = editButton;
        
    }
    
    else {
        
        // Кнопки нужно пересоздавать (Edit ---> Done)
        UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                    target:self
                                                                                    action:@selector(editAction:)];
        
        self.navigationItem.rightBarButtonItem = editButton;
        
    }
    
}

- (void) addAction:(UIBarButtonItem*) sender { // Метод для добавления директорий
    
    // делаем всплывающее окно с UITextField
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Create Directory"
                               message:@"Enter the name"
                              delegate:self
                     cancelButtonTitle:@"cancel"
                     otherButtonTitles:nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView addButtonWithTitle:@"create"];
    
    [alertView show];
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex { // Метод UIAlertViewDelegate для реализации действия при нажатии на кнопку. (create)

    UITextField* textField = [alertView textFieldAtIndex:0]; // Единственный UITextField, поэтому его индекс - 0
    
    NSString* newDirectoryName = [textField text];
    
    NSString* path = [self.path stringByAppendingPathComponent:newDirectoryName];
    
    NSError* error = nil;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:NO
                                               attributes:nil
                                                    error:&error];
    
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error];
    
    if (error) {
        
        NSLog(@"%@", [error localizedDescription]);
        
    }
    
    [self hideSecretFiles]; // прячем скрытые файлы, иначе после создания папки, они вновь появляются
    
    [self.tableView reloadData];
    
    [self alphabetOrderOfDirectoriesAndFiles];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return [self.contents count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* fileIdentifier = @"fileCell";
    static NSString* folderIdentifier = @"folderCell";
    
    // СТРОИМ В СТОРИБОРДЕ СУПЕРМЕН ЯЧЕЙКИ, ГОТОВИМСЯ К РЕКУРСИИ!!!
    
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        // если в ячейке директория
        
        EGFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:folderIdentifier];
        
        cell.folderName.text = fileName;
        
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        self.currentFolderSize = 0;
        
        NSMutableArray* foldersArray = [NSMutableArray arrayWithObject:path];
        
        cell.folderSize.text = [self folderSizeToCount:foldersArray]; // рекурсия! (подсчет размер папки)
        
        cell.folderImage.image = [UIImage imageNamed:@"folder.png"];
    
        return cell;
    
    } else {
        // Если в ячейке файл
        
        EGFileCell *cell = [tableView dequeueReusableCellWithIdentifier:fileIdentifier];
     
        cell.fileName.text = [NSString stringWithFormat:@"%@", fileName];
        
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        cell.fileSize.text = [self fileSizeFromValue:[attributes fileSize]];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:@"dd.MM.yyyy HH:mm"];
        
        NSDate* date = [attributes fileModificationDate];
        
        cell.fileDate.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
        
        cell.fileImage.image = [UIImage imageNamed:@"file.png"];
        
        return cell;
        
    }
    
    return nil;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    return YES;
//}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        
        // Если кликнули на папку, то создается новый EGTableViewController c содержимым кликнутой папки
        
        NSString* fileName = [self.contents objectAtIndex:indexPath.row];
        
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        EGTableViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EGTableViewController"];
        
        vc.path = path;
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
    
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Удаление папки/файла
    
    // удаляем файл из массива контента
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:self.contents];

    NSString* fileToDelete = [tempArray objectAtIndex:indexPath.row];

    [tempArray removeObject:fileToDelete];
    
    self.contents = tempArray;
    
    NSError* error = nil;
    
    NSString* path = [self.path stringByAppendingPathComponent:fileToDelete];
    
    // Убираем файлменеджером файл (безвозвратное удаление)
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    if (error) {
        
        NSLog(@"%@", [error localizedDescription]);
        
    }
    
    [self.tableView beginUpdates];
    // анимация удаления
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    [self.tableView endUpdates];
    
}

@end
