//
//  Defaults.h
//  Copeo
//
//  Created by Chiunti on 18/02/15.
//  Copyright (c) 2015 Chiunti Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

NSMutableArray *lugares;


//definicion de estados de la agenda
typedef enum{Insert,Delete,Edit,Show,Idle} copeoState;

// declaracion de estado de la agenda
copeoState currentState;



@interface Defaults : NSObject

@end
