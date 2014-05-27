#import "OCDXMLReportGenerator.h"
#import "OCDifference.h"

@implementation OCDXMLReportGenerator

- (void)generateReportForDifferences:(NSArray *)differences title:(NSString *)title {
    NSXMLElement *rootElement = [NSXMLElement elementWithName:@"differences"];
    if (title != nil) {
        [rootElement addAttribute:[NSXMLNode attributeWithName:@"title" stringValue:title]];
    }

    for (OCDifference *difference in differences) {
        NSXMLElement *differenceElement = [NSXMLElement elementWithName:@"difference"];
        [differenceElement addChild:[NSXMLElement elementWithName:@"type" stringValue:[self stringForDifferenceType:difference.type]]];
        [differenceElement addChild:[NSXMLElement elementWithName:@"name" stringValue:difference.name]];
        [differenceElement addChild:[NSXMLElement elementWithName:@"path" stringValue:difference.path]];
        [differenceElement addChild:[NSXMLElement elementWithName:@"lineNumber" stringValue:[NSString stringWithFormat:@"%tu", difference.lineNumber]]];

        if ([difference.modifications count] > 0) {
            NSXMLElement *modificationsElement = [NSXMLElement elementWithName:@"modifications"];

            for (OCDModification *modification in difference.modifications) {
                NSXMLElement *modificationElement = [NSXMLElement elementWithName:@"modification"];
                [modificationElement addChild:[NSXMLElement elementWithName:@"type" stringValue:[self stringForModificationType:modification.type]]];
                [modificationElement addChild:[NSXMLElement elementWithName:@"previousValue" stringValue:modification.previousValue]];
                [modificationElement addChild:[NSXMLElement elementWithName:@"currentValue" stringValue:modification.currentValue]];

                [modificationsElement addChild:modificationElement];
            }

            [differenceElement addChild:modificationsElement];
        }

        [rootElement addChild:differenceElement];
    }

    NSXMLDocument *document = [NSXMLDocument documentWithRootElement:rootElement];
    [document setCharacterEncoding:@"UTF-8"];

    printf("%s", [[document XMLStringWithOptions:NSXMLNodePrettyPrint] UTF8String]);
}

- (NSString *)stringForDifferenceType:(OCDifferenceType)type {
    switch (type) {
        case OCDifferenceTypeRemoval:
            return @"removal";

        case OCDifferenceTypeAddition:
            return @"addition";

        case OCDifferenceTypeModification:
            return @"modification";
    }

    abort();
}

- (NSString *)stringForModificationType:(OCDModificationType)type {
    switch (type) {
        case OCDModificationTypeDeclaration:
            return @"declaration";

        case OCDModificationTypeAvailability:
            return @"availability";

        case OCDModificationTypeDeprecationMessage:
            return @"deprecationMessage";

        case OCDModificationTypeSuperclass:
            return @"superclass";

        case OCDModificationTypeProtocols:
            return @"protocols";

        case OCDModificationTypeOptional:
            return @"optional";

        case OCDModificationTypeHeader:
            return @"header";
    }

    abort();
}

@end