#import "ADDispatchQueue.h"

#import "ADOperationMonitor.h"

#import "ADDispatchArcDefs.h"

@interface ADDispatchQueue ()

@property ( nonatomic, strong ) NSString* name;
@property ( nonatomic, assign ) BOOL isConcurrent;
@property ( nonatomic, AD_DISPATCH_PROPERTY ) dispatch_queue_t queue;

@end

@implementation ADDispatchQueue

@synthesize name;
@synthesize isConcurrent;
@synthesize queue = _queue;

-(id)initWithName:( NSString* )name_ concurrent:( BOOL )concurrent_
{
   self = [ super init ];
   if ( self )
   {
      self.name = name_;
      self.isConcurrent = concurrent_;
   }
   return self;
}

-(void)dealloc
{
   AD_DISPATCH_RELEASE( _queue );
}

+(id)concurrentQueueWithName:( NSString* )name_
{
   return [ [ self alloc ] initWithName: name_ concurrent: YES ];
}

+(id)serialQueueWithName:( NSString* )name_
{
   return [ [ self alloc ] initWithName: name_ concurrent: NO ];
}

-(dispatch_queue_t)createQueue
{
   if ( self.isConcurrent )
   {
      //return dispatch_queue_create( [ self.name UTF8String ], DISPATCH_QUEUE_CONCURRENT );
      return dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT , 0 );
   }

   return dispatch_queue_create( [ self.name UTF8String ], DISPATCH_QUEUE_SERIAL );
}

-(dispatch_queue_t)queue
{
   if ( !_queue )
   {
      _queue = [ self createQueue ];
      AD_DISPATCH_RETAIN( _queue );
   }
   return _queue;
}

-(void)async:( ADQueueBlock )block_
{
   dispatch_async( self.queue, block_ );
}

-(void)pause
{
   dispatch_suspend( self.queue );
}

-(void)resume
{
   dispatch_resume( self.queue );
}

@end



@implementation ADDispatchQueue (Monitor)

-(void)async:( ADQueueBlock )block_
 withMonitor:( ADOperationMonitor* )monitor_
{
   dispatch_group_async( monitor_.group, self.queue, block_ );
}

-(void)reqisterCompleteBlock:( ADQueueBlock )complete_block_
                  forMonitor:( ADOperationMonitor* )monitor_
{
   dispatch_group_notify( monitor_.group, self.queue, complete_block_ );
}

@end
