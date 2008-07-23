/* PieChartDS */

#import <Cocoa/Cocoa.h>
#import <SM2DGraphView/SMPieChartView.h>

@interface PieChartDS : NSObject
{
	NSMutableArray *skillGroups;
	NSMutableArray *sgPoints;
	NSNumberFormatter *formatter;
	NSMutableArray *colors;
}

- (PieChartDS *) init;
- (unsigned int)numberOfSlicesInPieChartView:(SMPieChartView *)inPieChartView;

- (double)pieChartView:(SMPieChartView *)inPieChartView dataForSliceIndex:(unsigned int)inSliceIndex;	
- (NSString *)pieChartView:(SMPieChartView *)inPieChartView labelForSliceIndex:(unsigned int)inSliceIndex; 

- (NSDictionary *)pieChartView:(SMPieChartView *)inPieChartView attributesForSliceIndex:(unsigned int)inSliceIndex;

- (void) clearSkillGroups;
- (void) addSkillGroup:(NSString *) name skillpoints:(int) sp;

@end
