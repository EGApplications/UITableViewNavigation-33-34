//
//  EGTableViewController.h
//  UITableViewNavigation #33-34
//
//  Created by Евгений Глухов on 01.07.15.
//  Copyright (c) 2015 EGApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EGTableViewController : UITableViewController

@property (strong, nonatomic) NSString* path;
@property (strong, nonatomic) NSArray* contents;

@property (strong, nonatomic) NSArray* tempFolderContents;

@property (strong, nonatomic) IBOutlet UITableView* tableView;

- (id) initWithFolderPath:(NSString*) path;


@end

/*
 
 Я рекомендую вам немного задержаться на этом уроке и снова попрактиковать таблицы. Также будет довольно таки неплохо если вы углубитесь в NSFileManager
 
 Ученик.
 
 1. Добавьте возможность создавать директории +++
 2. Добавьте возможность удалять файлы и папки +++
 
 Студент
 
 3. Сортируйте файлы и папки, сверху должны быть папки, снизу файлы, сортировка по имени +++
 4. Не показывайте скрытые файлы +++
 
 Мастер
 
 5. В detailedTextField каждой ячейки файла, выводите размер файла. +++
 
 Супермен
 
 6. Тем же способом выводите размер папки (размер папки придется считать рекурсивно :) )
 
 */