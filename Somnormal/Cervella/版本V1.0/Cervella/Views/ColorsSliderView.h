//
//  ColorsSliderView.h
//  Cervella
//
//  Created by 一磊 on 2018/6/13.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define colorSliderWidth (self.frame.size.width/10.0 - colorSliderd_d)
#define colorSliderHeight (colorSliderWidth * 2.0)
#define colorSliderd_d 14.0


@protocol ColorsSliderViewDelegate <NSObject>
- (void)selectIndex:(NSInteger)index;
@end

@interface ColorsSliderView : UIView

@property (nonatomic, weak) id<ColorsSliderViewDelegate>delegate;
@property (nonatomic, assign) NSInteger level;
@end
