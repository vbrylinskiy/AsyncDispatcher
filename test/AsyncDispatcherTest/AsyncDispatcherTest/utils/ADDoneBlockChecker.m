#import "ADDoneBlockChecker.h"

#include <assert.h>

ADDoneBlock ADNotifySuccess( ADDoneBlock done_block_, GHAsyncTestCase* test_case_, SEL selector_ )
{
   return ^void( id< ADResult > result_ )
   {
      [ test_case_ notify: kGHUnitWaitStatusSuccess forSelector: selector_ ];
      if ( done_block_ )
         done_block_( result_ );
   };
}

ADDoneBlock ADCheckResultOnMainThread( ADDoneBlock done_block_, id expected_result_ )
{
   return ^void( id< ADResult > result_ )
   {
      assert( [ NSThread isMainThread ] && "ADCheckDoneOnMainThread" );
      if ( ![ expected_result_ isEqual: result_.result ] )
      {
         NSLog( @"Check result (%@) with expected result (%@)", result_.result, expected_result_ );
         assert( 0 );
      }

      if ( done_block_ )
         done_block_( result_ );
   };
}

ADDoneBlock ADCheckResultOnBackgroundThread( ADDoneBlock done_block_, id expected_result_ )
{
   NSThread* caller_thread_ = [ NSThread currentThread ];

   return ^void( id< ADResult > result_ )
   {
      assert( ![ NSThread isMainThread ] && "ADCheckResultOnBackgroundThread" );
      assert( [ NSThread currentThread ] != caller_thread_ && "ADCheckResultOnBackgroundThread" );

      if ( ![ expected_result_ isEqual: result_.result ] )
      {
         NSLog( @"Check result (%@) with expected result (%@)", result_.result, expected_result_ );
         assert( 0 );
      }

      if ( done_block_ )
         done_block_( result_ );
   };
}

ADDoneBlock ADCheckResultOnNotMainThread( ADDoneBlock done_block_, id expected_result_ )
{
   return ^void( id< ADResult > result_ )
   {
      assert( ![ NSThread isMainThread ] && "ADCheckResultOnNotMainThread" );

      if ( ![ expected_result_ isEqual: result_.result ] )
      {
         NSLog( @"Check result (%@) with expected result (%@)", result_.result, expected_result_ );
         assert( 0 );
      }

      if ( done_block_ )
         done_block_( result_ );
   };
}

ADDoneBlock ADCheckResultOnThisThread( ADDoneBlock done_block_, id expected_result_ )
{
   NSThread* caller_thread_ = [ NSThread currentThread ];

   return ^void( id< ADResult > result_ )
   {
      assert( [ NSThread currentThread ] == caller_thread_ && "ADCheckResultOnThisThread" );

      if ( ![ expected_result_ isEqual: result_.result ] )
      {
         NSLog( @"Check result (%@) with expected result (%@)", result_.result, expected_result_ );
         assert( 0 );
      }

      if ( done_block_ )
         done_block_( result_ );
   };
}
