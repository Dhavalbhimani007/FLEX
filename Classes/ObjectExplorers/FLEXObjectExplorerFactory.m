//
//  FLEXObjectExplorerFactory.m
//  Flipboard
//
//  Created by Ryan Olson on 5/15/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXObjectExplorerFactory.h"
#import "FLEXGlobalsViewController.h"
#import "FLEXClassShortcuts.h"
#import "FLEXViewShortcuts.h"
#import "FLEXViewControllerShortcuts.h"
#import "FLEXUIAppShortcuts.h"
#import "FLEXImageShortcuts.h"
#import "FLEXLayerShortcuts.h"
#import "FLEXColorPreviewSection.h"
#import "FLEXDefaultsContentSection.h"
#import "FLEXBundleShortcuts.h"
#import "FLEXBlockShortcuts.h"
#import "FLEXUtility.h"

@implementation FLEXObjectExplorerFactory
static NSMutableDictionary<id<NSCopying>, Class> *classesToRegisteredSections = nil;

+ (void)initialize {
    if (self == [FLEXObjectExplorerFactory class]) {
        // DO NOT USE STRING KEYS HERE
        // We NEED to use the class as a key, because we CANNOT
        // differentiate a class's name from the metaclass's name.
        // These mappings are per-class-object, not per-class-name.
        //
        // For example, if we used class names, this would result in
        // the object explorer trying to render a color preview for
        // the UIColor class object, which is not a color itself.
        #define ClassKey(name) (id<NSCopying>)[name class]
        #define ClassKeyByName(str) (id<NSCopying>)NSClassFromString(@ #str)
        #define MetaclassKey(meta) (id<NSCopying>)object_getClass([meta class])
        classesToRegisteredSections = [NSMutableDictionary dictionaryWithDictionary:@{
            MetaclassKey(NSObject)     : [FLEXClassShortcuts class],
            ClassKey(NSArray)          : [FLEXCollectionContentSection class],
            ClassKey(NSSet)            : [FLEXCollectionContentSection class],
            ClassKey(NSDictionary)     : [FLEXCollectionContentSection class],
            ClassKey(NSOrderedSet)     : [FLEXCollectionContentSection class],
            ClassKey(NSUserDefaults)   : [FLEXDefaultsContentSection class],
            ClassKey(UIViewController) : [FLEXViewControllerShortcuts class],
            ClassKey(UIApplication)    : [FLEXUIAppShortcuts class],
            ClassKey(UIView)           : [FLEXViewShortcuts class],
            ClassKey(UIImage)          : [FLEXImageShortcuts class],
            ClassKey(CALayer)          : [FLEXLayerShortcuts class],
            ClassKey(UIColor)          : [FLEXColorPreviewSection class],
            ClassKey(NSBundle)         : [FLEXBundleShortcuts class],
            ClassKeyByName(NSBlock)    : [FLEXBlockShortcuts class],
        }];
        #undef ClassKey
        #undef ClassKeyByName
        #undef MetaclassKey
    }
}

+ (FLEXObjectExplorerViewController *)explorerViewControllerForObject:(id)object {
    // Can't explore nil
    if (!object) {
        return nil;
    }

    // If we're given an object, this will look up it's class hierarchy
    // until it finds a registration. This will work for KVC classes,
    // since they are children of the original class, and not siblings.
    // If we are given an object, object_getClass will return a metaclass,
    // and the same thing will happen. FLEXClassShortcuts is the default
    // shortcut section for NSObject.
    //
    // TODO: rename it to FLEXNSObjectShortcuts or something?
    Class sectionClass = nil;
    Class cls = object_getClass(object);
    do {
        sectionClass = classesToRegisteredSections[(id<NSCopying>)cls];
    } while (!sectionClass && (cls = [cls superclass]));

    if (!sectionClass) {
        sectionClass = [FLEXShortcutsSection class];
    }

    return [FLEXObjectExplorerViewController
        exploringObject:object
        customSection:[sectionClass forObject:object]
    ];
}

+ (void)registerExplorerSection:(Class)explorerClass forClass:(Class)objectClass {
    classesToRegisteredSections[(id<NSCopying>)objectClass] = explorerClass;
}

#pragma mark - FLEXGlobalsEntry

+ (NSString *)globalsEntryTitle:(FLEXGlobalsRow)row  {
    switch (row) {
        default: return nil;
    }
}

+ (UIViewController *)globalsEntryViewController:(FLEXGlobalsRow)row  {
    return nil;
}

+ (FLEXGlobalsEntryRowAction)globalsEntryRowAction:(FLEXGlobalsRow)row {
    return nil;
}

@end
