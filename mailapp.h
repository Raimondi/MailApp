/*
 *  mailapp.h
 *  mailapp
 *
 *  Created by Israel Chauca on 8/30/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

@interface QueryFactory : NSObject
{
	ABSearchElement
	* theQuery,
	* firstName,
	* firstNamePhonetic,
	* lastName,
	* lastNamePhonetic,
	* maidenName,
	* middleName,
	* middleNamePhonetic,
	* nickName,
	* email,
	* firstName2,
	* firstNamePhonetic2,
	* lastName2,
	* lastNamePhonetic2,
	* maidenName2,
	* middleName2,
	* middleNamePhonetic2,
	* nickName2,
	* email2;
}

- (void)searchAndPrint: NSString;
@end

@interface SendMail : NSObject
{
	NSString *from;
	NSString *to;
	NSString *cc;
	NSString *bcc;
	NSString *subject;
	NSString *attachment;
	NSString *body;
	NSInteger sendMsg;
	NSInteger visible;
	
}

@property(readwrite, assign) NSString *from;
@property(readwrite, assign) NSString *to;
@property(readwrite, assign) NSString *cc;
@property(readwrite, assign) NSString *bcc;
@property(readwrite, assign) NSString *subject;
@property(readwrite, assign) NSString *attachment;
@property(readwrite, assign) NSString *body;
@property(readwrite, assign) NSInteger sendMsg;
@property(readwrite, assign) NSInteger visible;

-(void)sendEmailMessage;

@end
