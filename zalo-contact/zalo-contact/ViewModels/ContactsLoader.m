//
//  ContactsLoader.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactsLoader.h"
#import "../Models/Contact.h"

extern NSString *image1 = @"https://i.guim.co.uk/img/media/66e444bff77d9c566e53c8da88591e4297df0896/120_0_1800_1080/master/1800.png?width=1200&height=1200&quality=85&auto=format&fit=crop&s=69b22b4292160faf91cb45ad024fc649";
extern NSString *image2 = @"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6yFzIYiRlIzc_Nb_KD3lmSmvtmJxr4eboXw&usqp=CAU";

extern NSString *image3 = @"https://publish.one37pm.net/wp-content/uploads/2020/12/screen-shot-2020-12-23-at-11-54-06-am.png?fit=750%2C775";

extern NSString *image4 = @"https://5b0988e595225.cdn.sohucs.com/images/20180609/e28ffe23ba7941dd9993a8e0c6f596c9.jpeg";
extern NSString *image5 = @"https://variety.com/wp-content/uploads/2021/07/Pokemon.jpg";

extern NSString *image6 = @"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtQdzeTZ_qVpCnTMewV-f7VSyO-r3LiaRZQ_CHz5e4x8JPR4cZRXWccKjKsWpWjWC2s84&usqp=CAU";

@implementation ContactsLoader {
    NSMutableArray<ContactGroup *> *_contactGroups;
}

-(NSMutableArray<ContactGroup *> *) contactGroup {
    if (!_contactGroups) {
//        [self update];
        return @[];
    }
    return _contactGroups;
}

-(void) update {
    _contactGroups = [self contactGroupFromContactsList: self.fetchAllContacts];
}

//MARK: - performance - warning
- (NSMutableArray<ContactGroup *> *) contactGroupFromContactsList:(NSArray<Contact *> *)list {
    NSArray *distinctHeader;
    
    NSMutableDictionary *result = [NSMutableDictionary new];
    distinctHeader = [list valueForKeyPath:@"@distinctUnionOfObjects.header"];
    
    //MARK: - performance - warning
    for (NSString *charactor in distinctHeader) {
//        Nặng
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"header = %@", charactor];
        NSArray *persons = [list filteredArrayUsingPredicate:predicate];
        [result setObject:persons forKey:charactor];
    }
    
    NSArray *sortedKeys = [distinctHeader sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSLog(@"%s Sorted key %@", __PRETTY_FUNCTION__, sortedKeys);
    
    NSMutableArray<ContactGroup *> *groups = NSMutableArray.new;
    
    for (NSString *key in sortedKeys) {
        NSArray *arr = [result[key] sortedArrayUsingComparator:^NSComparisonResult(Contact *a, Contact *b) {
            return [a.fullName compare:b.fullName];
        }];//
        [groups addObject:[ContactGroup.alloc initWithContactArray:arr]];
    }
    return groups;
}

//MARK: - background
-(NSArray<Contact *>*) fetchAllContacts {
    NSMutableArray<Contact *> *contactsArray = [[NSMutableArray alloc] initWithArray: @[]];

    for (CNContact *contact in UserContacts.sharedInstance.getContactList) {
        [contactsArray addObject:[ContactAdapter.alloc initWithCNContact: contact]];
    }
    
    //sort if
    //stress test the list
    for (int i = 0; i < 8; i++) {
        [contactsArray addObjectsFromArray:[[NSMutableArray alloc] initWithArray: @[
            [[Contact alloc] initWithFirstName:@"Thiện "
                                      lastName:@"Nguyễn"
                                   phoneNumber:@"0123456789"
                                      imageUrl:image1],
            [[Contact alloc] initWithFirstName:@"Thiện"
                                      lastName:@"Công"
                                   phoneNumber:@"0123456789"
                                      imageUrl:image2],
            [[Contact alloc] initWithFirstName:@"Tính"
                                      lastName:@"Thiên"
                                   phoneNumber:@"0123456789"
                                      imageUrl:image3],
            [[Contact alloc] initWithFirstName:@"Vũ"
                                      lastName:@"Hoàng"
                                   phoneNumber:@"0123456789"
                                      imageUrl:image4],
            [[Contact alloc] initWithFirstName:@"Vân"
                                      lastName:@"Hồ"
                                   phoneNumber:@"0123456789"
                                      imageUrl:image5],
            [[Contact alloc] initWithFirstName:@"Vân"
                                      lastName:@"Lê"
                                   phoneNumber:@"0123456789"
                                      imageUrl:image6],
        ]]];
    }
    return contactsArray;
}
@end



