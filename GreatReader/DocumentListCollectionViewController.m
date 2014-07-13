//
//  DocumentListCollectionViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/6/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentListCollectionViewController.h"

#import "Device.h"
#import "DocumentListViewModel.h"
#import "NSArray+GreatReaderAdditions.h"
#import "DocumentCollectionViewCell.h"
#import "PDFDocument.h"
#import "PDFDocumentStore.h"
#import "PDFRecentDocumentList.h"
#import "PDFDocumentViewController.h"

@interface DocumentListCollectionViewController ()
@end

@implementation DocumentListCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.allowsMultipleSelection = YES;    
}

- (void)deselectAll:(BOOL)animated
{
    [[self.collectionView indexPathsForSelectedItems]
            enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self.collectionView deselectItemAtIndexPath:indexPath
                                             animated:animated];
    }];
}

- (void)registerNibForCell
{
    NSString *nibName = @"DocumentCollectionViewCell";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nibName = [nibName stringByAppendingString:@"_iPad"];
    } else {
        nibName = [nibName stringByAppendingString:@"_iPhone"];
    }
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    [self.collectionView registerNib:nib
          forCellWithReuseIdentifier:DocumentListViewControllerCellIdentifier];
}

- (void)reloadView
{
    [self.collectionView reloadData];
}

- (NSArray *)selectedIndexPaths
{
    return self.collectionView.indexPathsForSelectedItems;
}

- (void)deleteCellsAtIndexPaths:(NSArray *)indexPaths
{
    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
}

- (void)openDocumentsAtURL:(NSURL *)URL
{
    for (int i = 0; i < self.viewModel.count; i++) {
        PDFDocument *document = [self.viewModel documentAtIndex:i];
        if ([document.path.lastPathComponent isEqual:URL.lastPathComponent]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath
                                              animated:YES
                                        scrollPosition:UICollectionViewScrollPositionCenteredVertically];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                [self performSegueWithIdentifier:DocumentListViewControllerSeguePDFDocument
                                          sender:cell];                                        
            });
        }
    }
}

#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        [self updateButtonsEnabled];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        [self updateButtonsEnabled];
    } else {
        [self performSegueWithIdentifier:DocumentListViewControllerSeguePDFDocument
                                  sender:[collectionView cellForItemAtIndexPath:indexPath]];
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.editing) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        cell.highlighted = NO;
    }
}

#pragma mark -

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DocumentCollectionViewCell *cell =
            [collectionView dequeueReusableCellWithReuseIdentifier:DocumentListViewControllerCellIdentifier
                                                      forIndexPath:indexPath];

    PDFDocument *document = [self.viewModel documentAtIndex:indexPath.item];
    cell.document = document;
    
    return cell;    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewModel.count;
}

#pragma mark -

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return IsPad() ? CGSizeMake(180, 230) : CGSizeMake(100, 140);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return IsPad() ? 20 : 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return IsPad() ? UIEdgeInsetsMake(40, 20, 40, 20) : UIEdgeInsetsMake(20, 10, 20, 10);
}


@end