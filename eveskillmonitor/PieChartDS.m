#import "PieChartDS.h"

@implementation PieChartDS

- (PieChartDS *) init
{
	skillGroups = [[NSMutableArray alloc] initWithCapacity:7];
	sgPoints = [[NSMutableArray alloc] initWithCapacity:7];
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setFormat:@"#,##0"];
	colors = [[NSMutableArray alloc] initWithCapacity: 17];
	[colors addObject:[NSColor blueColor]];
	[colors addObject:[NSColor cyanColor]];
	[colors addObject:[NSColor darkGrayColor]];
	[colors addObject:[NSColor greenColor]];
	[colors addObject:[NSColor magentaColor]];
	[colors addObject:[NSColor orangeColor]];
	[colors addObject:[NSColor grayColor]];
	[colors addObject:[NSColor purpleColor]];
	[colors addObject:[NSColor redColor]];
	[colors addObject:[NSColor whiteColor]];
	[colors addObject:[NSColor yellowColor]];
	[colors addObject:[NSColor lightGrayColor]];
	[colors addObject:[NSColor brownColor]];
	[colors addObject:[NSColor blackColor]];
	[colors addObject:[NSColor clearColor]];
	[colors addObject:[NSColor highlightColor]];
	return self;
}
	
- (unsigned int)numberOfSlicesInPieChartView:(SMPieChartView *)inPieChartView
{
	return [skillGroups count];
}

- (NSDictionary *)pieChartView:(SMPieChartView *)inPieChartView attributesForSliceIndex:(unsigned int)inSliceIndex
{
	return [NSDictionary dictionaryWithObject:[colors objectAtIndex:inSliceIndex] forKey:NSBackgroundColorAttributeName];
}

- (double)pieChartView:(SMPieChartView *)inPieChartView dataForSliceIndex:(unsigned int)inSliceIndex
{
	return [[sgPoints objectAtIndex:inSliceIndex] intValue];
}
	
- (NSString *)pieChartView:(SMPieChartView *)inPieChartView labelForSliceIndex:(unsigned int)inSliceIndex
{
	return [NSString stringWithFormat:@"%@ (%@)", [skillGroups objectAtIndex:inSliceIndex], [formatter stringFromNumber:[sgPoints objectAtIndex:inSliceIndex]]];
}

- (void) clearSkillGroups
{
	[skillGroups removeAllObjects];
	[sgPoints removeAllObjects];
}
	
- (void) addSkillGroup:(NSString *) name skillpoints:(int) sp
{
	[skillGroups addObject:name];
	[sgPoints addObject:[NSNumber numberWithInt:sp]];
}

- (void) dealloc
{
	[skillGroups release];
	[sgPoints release];
	[formatter release];
	[super dealloc];
}

@end
