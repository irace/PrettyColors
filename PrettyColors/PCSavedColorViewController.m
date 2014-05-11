//
//  PCSavedColorViewController.m
//  Pretty Colors
//
//  Created by Bryan Irace on 8/20/13.
//  Copyright (c) 2013 Bryan Irace. All rights reserved.
//

#import "PCSavedColorViewController.h"

#import "PCSavedColorCell.h"

static NSString * const PCSavedColorCellIdentifier = @"PCSavedColorCellIdentifier";

@interface PCSavedColorViewController ()

@end

@implementation PCSavedColorViewController

- (id)init {
    UICollectionViewLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    if (self = [super initWithCollectionViewLayout:layout]) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[PCSavedColorCell class] forCellWithReuseIdentifier:PCSavedColorCellIdentifier];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PCSavedColorCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:PCSavedColorCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    
    return cell;
}

@end
