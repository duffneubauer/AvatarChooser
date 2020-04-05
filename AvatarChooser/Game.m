//
//  Game.m
//  avatar-chooser
//
//  Created by Duff Neubauer on 4/5/20.
//  Copyright © 2020 Duff Neubauer. All rights reserved.
//

#import "Game.h"

#import "Avatar.h"

@interface Game ()
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray<Avatar *> *avatars;

// For suggesting avatars
@property (nonatomic) NSInteger numberOfSuggestions;
@property (nonatomic) NSInteger lastSuggestionIndex;

@end

@interface NSArray (ACShuffle)
- (NSArray *)ac_shuffle;
@end

@implementation Game

- (instancetype)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        self.name = json[@"name"];
        
        NSMutableArray<Avatar *> *avatars = [@[] mutableCopy];
        NSArray *avatarListJSON = json[@"avatars"];
        for (NSDictionary *avatarJSON in avatarListJSON) {
            [avatars addObject:[[Avatar alloc] initWithJSON:avatarJSON]];
        }
        self.avatars = avatars;
        self.numberOfSuggestions = 5;
        self.lastSuggestionIndex = NSNotFound;
    }
    
    return self;
}

- (NSUInteger)numberOfAvatars {
    return self.avatars.count;
}

- (void)resetAvatarSuggestions {
    self.avatars = [self.avatars ac_shuffle];
    self.lastSuggestionIndex = NSNotFound;
}

- (NSArray<Avatar *> *)suggestNewAvatars {
    NSInteger nextStartIndex;
    if (self.lastSuggestionIndex == NSNotFound) {
        nextStartIndex = 0;
    } else {
        nextStartIndex = MIN(self.lastSuggestionIndex + self.numberOfSuggestions, self.avatars.count);
    }
    
    return [self _suggestAvatarsFromIndex:nextStartIndex];
}

- (NSArray<Avatar *> *)previousAvatarSuggestion {
    NSInteger previousIndex;
    if (self.lastSuggestionIndex < self.avatars.count) {
        previousIndex = self.lastSuggestionIndex - self.numberOfSuggestions;
    } else {
        previousIndex = self.avatars.count - (self.avatars.count % self.numberOfSuggestions);
    }
    return [self _suggestAvatarsFromIndex:previousIndex];
}

- (NSArray<Avatar *> *)_suggestAvatarsFromIndex:(NSInteger)index {
    NSArray<Avatar *> *suggestion;
    if (index < 0) {
        self.lastSuggestionIndex = NSNotFound;
        suggestion = @[];
    } else if (index >= self.avatars.count) {
        self.lastSuggestionIndex = self.avatars.count;
        suggestion = @[];
    } else {
        self.lastSuggestionIndex = index;
        NSInteger numberOfAvatarsToSuggest = MIN(self.avatars.count - index, self.numberOfSuggestions);
        suggestion = [self.avatars subarrayWithRange:NSMakeRange(index, numberOfAvatarsToSuggest)];
    }
    
    return suggestion;
}

@end

@implementation NSArray (ACShuffle)

/// Fisher–Yates shuffle (https://en.wikipedia.org/wiki/Fisher–Yates_shuffle)
- (NSArray *)ac_shuffle {
    NSMutableArray *result = [NSMutableArray arrayWithArray:self];
    for (int i = (int)self.count - 1; i > 0; i--) {
        int j = arc4random_uniform(i); // Generates a random number in the range [0, i)
        [result exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    
    return result;
}

@end
