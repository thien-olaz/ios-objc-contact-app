//
//  commonMacro.h
//  zalo-contact
//
//  Created by Thiện on 28/12/2021.
//

#ifndef commonMacro_h
#define commonMacro_h

#define GLOBAL_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
#define MAIN_QUEUE dispatch_get_main_queue()

#define IS_CURRENT_QUEUE(queue) dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(queue)


#define SET_SPECIFIC_FOR_QUEUE(queue) dispatch_queue_set_specific(queue, dispatch_queue_get_label(queue), (void *)dispatch_queue_get_label(queue), NULL)

#define DISPATCH_ASYNC_IF_NOT_IN_QUEUE(queue, block) \
if(dispatch_get_specific(dispatch_queue_get_label(queue))) { \
    block(); \
} else { \
    dispatch_async(queue, block); \
}

#define DISPATCH_SYNC_IF_NOT_IN_QUEUE(queue, block) \
if(dispatch_get_specific(dispatch_queue_get_label(queue))) { \
    block(); \
} else { \
    dispatch_sync(queue, block); \
}


#endif /* commonMacro_h */
