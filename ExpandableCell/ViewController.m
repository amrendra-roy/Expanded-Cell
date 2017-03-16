//
//  ViewController.m
//  ExpandableCell
//
//  Created by Amrendra Roy on 14/03/17.
//  Copyright © 2017 Amrendra. All rights reserved.
//

#import "ViewController.h"
#import "HeaderView.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *arrOfList;
    int alreadyExpandedSection;//Default -1
    
    
    __weak IBOutlet UITableView *tblView;
    
    NSMutableArray *arOfHeaderView;//An array which contains the Headerviews collection, it will reuse header if already created
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrOfList = [[NSMutableArray alloc] init];
    
    
    //Dictionary with Section title and Subcat (Subcat for cells)
    [arrOfList addObject:@{@"Title" : @"Section Title 0",
                            @"SubCat" : @[
                                    @{@"SubTitle" : @"SubTitle 01"},
                                    @{@"SubTitle" : @"SubTitle 02"}
                                    ]
                            
                            }];
     [arrOfList addObject:@{ @"Title" : @"Section Title 1",
                                @"SubCat" : @[
                                                @{@"SubTitle" : @"SubTitle 11"},
                                            ]
        
                             }];
    
       [arrOfList addObject:@{@"Title" : @"Section Title 2",
                              @"SubCat" : @[ ]
                               }];
       [arrOfList addObject:@{@"Title" : @"Section Title 3",
                               @"SubCat" : @[
                                       @{@"SubTitle" : @"SubTitle 31"},
                                       @{@"SubTitle" : @"SubTitle 32"}
                                       ]
                               
                               }];
    
    

    alreadyExpandedSection = -1;
    arOfHeaderView = [[NSMutableArray alloc] init];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    arOfHeaderView = nil;
    arrOfList = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrOfList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *di = [arrOfList objectAtIndex:section];
    NSArray *ar = [di objectForKey:@"SubCat"];
    
    if (alreadyExpandedSection == -1) {
        return 0;
    }
    else if(ar.count && alreadyExpandedSection == section)
        return ar.count;
    else
        return 0;

    
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *di = [arrOfList objectAtIndex:indexPath.section];
    NSArray *ar = [di objectForKey:@"SubCat"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"childCell" forIndexPath:indexPath];
    NSDictionary *subDi = [ar objectAtIndex:indexPath.row];

    cell.textLabel.text = [subDi objectForKey:@"SubTitle"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"move to next view for Section = %d, Row = %d",indexPath.section, indexPath.row);
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 60;
    }
   return 45;

    //return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 60;
    }
    return 45;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    HeaderView *headerView;
    if(arOfHeaderView.count>section)
       headerView = [arOfHeaderView objectAtIndex:section];
    
    if (!headerView) {
        HeaderView *view = [[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil][0];
        view.titleLabel.text = [NSString stringWithFormat:@"Section title %d",section];
        
        NSDictionary *di = [arrOfList objectAtIndex:section];
        NSArray *ar = [di objectForKey:@"SubCat"];
        
        if (ar.count) {
            if (alreadyExpandedSection == section) {
                view.plusMinesLabel.text = @"-";
            }
            else
                view.plusMinesLabel.text = @"+";
            
        }else {
            view.plusMinesLabel.text = @">";
        }
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTappedSection:)];
        view.tag = section;
        [view addGestureRecognizer:gesture];
        
        [arOfHeaderView addObject:view];
        headerView = view;
    }
    return headerView;
    
}

- (void)didTappedSection:(UITapGestureRecognizer*)gesture
{
    HeaderView *gestureView = (HeaderView*)gesture.view;
    
    NSLog(@"Section header Tapped = %d",gestureView.tag);
    int section = gestureView.tag;
    NSDictionary *di = [arrOfList objectAtIndex:section];
    NSArray *ar = [di objectForKey:@"SubCat"];
    if (!ar.count) {
        
        NSLog(@"Move to next view controller");
    }
    else
    {
            if (alreadyExpandedSection == -1) {
                alreadyExpandedSection = section;
                gestureView.plusMinesLabel.text = @"-";

                [self insertCellsForSection:section];
            }
            else if(alreadyExpandedSection == section){//delete cells if same section is selected
                alreadyExpandedSection = -1;
                gestureView.plusMinesLabel.text = @"+";

                [self deleteCellsForSection:section];

            } else {   //Selected new section, Than delete already expanded section and expand new section
                
                HeaderView *headerview = [arOfHeaderView objectAtIndex:alreadyExpandedSection];
                headerview.plusMinesLabel.text = @"+";
                
                NSMutableArray *arrOfIndexPath = [[NSMutableArray alloc] init];
                NSDictionary *di = [arrOfList objectAtIndex:alreadyExpandedSection];
                NSArray *ar = [di objectForKey:@"SubCat"];
                for (int i = 0; i< ar.count; i++){
                    
                    [arrOfIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:alreadyExpandedSection]];
                }
               
                alreadyExpandedSection = -1;//This value should updat before updating the table

                [tblView beginUpdates];
                [tblView deleteRowsAtIndexPaths:arrOfIndexPath withRowAnimation:UITableViewRowAnimationFade];
                [tblView endUpdates];
                
                
                alreadyExpandedSection = section;
                gestureView.plusMinesLabel.text = @"-";
                [self insertCellsForSection:section];
            }
    }
}
- (void)insertCellsForSection:(NSInteger)section
{
    NSMutableArray *arrOfIndexPath = [[NSMutableArray alloc] init];
    NSDictionary *di = [arrOfList objectAtIndex:section];
    NSArray *ar = [di objectForKey:@"SubCat"];
    for (int i = 0; i< ar.count; i++){
        
        [arrOfIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    [tblView beginUpdates];
    [tblView insertRowsAtIndexPaths:arrOfIndexPath withRowAnimation:UITableViewRowAnimationFade];
    [tblView endUpdates];
    arrOfIndexPath = nil;
}
- (void)deleteCellsForSection:(NSInteger)section
{
    NSMutableArray *arrOfIndexPath = [[NSMutableArray alloc] init];
    NSDictionary *di = [arrOfList objectAtIndex:section];
    NSArray *ar = [di objectForKey:@"SubCat"];
    for (int i = 0; i< ar.count; i++){
        
        [arrOfIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    
    [tblView beginUpdates];
    [tblView deleteRowsAtIndexPaths:arrOfIndexPath withRowAnimation:UITableViewRowAnimationFade];
    [tblView endUpdates];
    arrOfIndexPath = nil;
}

@end
