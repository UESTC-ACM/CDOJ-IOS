//
//  CodeSubmitViewController.m
//  CDOJ-IOS
//
//  Created by Sunnycool on 16/8/21.
//  Copyright © 2016年 UESTCACM QKTeam. All rights reserved.
//

#import "CodeSubmitViewController.h"
#import "CodeSubmitModel.h"
#import "LocalDataModel.h"

@interface CodeSubmitViewController ()

@end

@implementation CodeSubmitViewController

- (instancetype)init {
    if(self = [super init]) {
        NSDictionary* destination = [LocalDataModel getCurrentProblemAndContest];
        if(destination) {
            self.problemId = STR([destination objectForKey:@"problemId"]);
            self.contestId = STR([destination objectForKey:@"contestId"]);
        }
        else {
            self.problemId = @"";
            self.contestId = @"";
        }
        NSLog(@"problemId = %@ in contestId = %@", self.problemId, self.contestId);
        
        NSMutableArray<UIBarButtonItem*>* rightItems = [self.navigationItem.rightBarButtonItems mutableCopy];
        [rightItems addObject:[[UIBarButtonItem alloc] initWithTitle:@"提交"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(submitCode)]];
        self.navigationItem.rightBarButtonItems = rightItems;
        
        self.languages = @[@"C", @"C++", @"Java"];
        self.languageChooser = [[UISegmentedControl alloc] initWithItems:self.languages];
        self.navigationItem.titleView = self.languageChooser;
        
        self.codeView = [[CodeEditorView alloc] init];
        [self.view addSubview:self.codeView];
        
        [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top);
            make.left.equalTo(self.view.mas_left);
            make.width.equalTo(self.view.mas_width);
            make.bottom.equalTo(self.copyright.mas_top);
        }];
        
        [self.languageChooser addTarget:self action:@selector(chooseLanguage:) forControlEvents:UIControlEventValueChanged];
        [self.languageChooser setSelectedSegmentIndex:1];
        [self chooseLanguage:self.languageChooser]; // call it manually for the first time
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitSucceed) name:NOTIFICATION_STATUS_SUBMIT_SUCCEED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitFailed) name:NOTIFICATION_STATUS_SUBMIT_FAILED object:nil];
    }
    return self;
}

- (void)submitCode {
    self.codeSubmitter = [[CodeSubmitModel alloc] initWithCode:self.codeView.text
                                                withLanguageId:self.languageChooser.selectedSegmentIndex + 1
                                                     toProblem:self.problemId
                                                     inContest:self.contestId];
    [self.codeSubmitter submit];
}
- (void)submitSucceed {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)submitFailed {
}
- (void)chooseLanguage:(UISegmentedControl*)languageChooser {
    NSString* language = self.languages[languageChooser.selectedSegmentIndex];
    [self.codeView setLanguageType:[CodeEditorLanguage getLanguageByFileSuffixName:language]];
}

@end
