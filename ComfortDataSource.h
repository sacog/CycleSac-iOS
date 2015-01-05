@interface ComfortDataSource : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>
{
	NSArray	*customPickerArray;
	id<UIPickerViewDelegate> parent;
    NSInteger pickerCategory;
}

@property (nonatomic, retain) NSArray *customPickerArray;
@property (nonatomic, retain) NSArray *pickerTitles;
@property (nonatomic, retain) NSArray *pickerImages;
@property (nonatomic, retain) id<UIPickerViewDelegate> parent;

@end