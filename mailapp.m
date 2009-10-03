#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "MLGlue/MLGlue.h"
#import "mailapp.h"

int main (int argc, const char **argv) {
	
	NSAutoreleasePool * pool   = [[NSAutoreleasePool alloc] init];
	NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
	NSString * listArg = [args stringForKey:@"list"];
	NSString * listFromArg = [args stringForKey:@"listfrom"];
	NSString * version = [NSString stringWithString:@"1.0"];

	if ( argc < 2 || (listFromArg == nil && listArg == nil && [args stringForKey:@"to"] == nil) ) {
	
		printf("mailapp %s\n", [version UTF8String]);
		exit(0);
	}
	
	if ( listFromArg ) {
		// List from emails
		MLApplication *mail = [MLApplication applicationWithName: @"Mail"];
		@try {
			MLReference *refAccounts = [mail accounts];
			id resultAccounts = [refAccounts getItem];
			
			for ( id anAccount in resultAccounts ) {
				MLReference *refFullName = [anAccount fullName];
				NSString * resultFullName = [refFullName getItem];
				//NSLog(@"%@", resultFullName);
				
				MLReference *refAddresses = [anAccount emailAddresses];
				id resultAddresses = [refAddresses getItem];
				
				for ( NSString * emailAddress in resultAddresses ) {
					printf("%s <%s>\n",[resultFullName UTF8String], [emailAddress UTF8String]);
				}
			}
		}@catch (NSException *e) {
			NSLog(@"Exception:%@");
		}
	} else if ( listArg ) {
		// Search and print:
		
		QueryFactory * theFactory = [[QueryFactory alloc] init];
		[theFactory searchAndPrint: listArg];
		
	}
	if ( [args stringForKey:@"to"] ) {
		// Send email:
		
		@try {
			// Initialize our object
			SendMail * aSendMail = [[SendMail alloc] init];
			
			// Set every field
			aSendMail.from = [args stringForKey:@"from"];
			aSendMail.to = [args stringForKey:@"to"];
			aSendMail.cc = [args stringForKey:@"cc"];
			aSendMail.bcc = [args stringForKey:@"bcc"];
			aSendMail.subject = [args stringForKey:@"subject"];
			aSendMail.body = [args stringForKey:@"body"];
			aSendMail.attachment = [args stringForKey:@"attachment"];
			aSendMail.sendMsg = [args boolForKey:@"send"];
			aSendMail.visible = [args boolForKey:@"visible"];
			
			// Send email:
			[aSendMail sendEmailMessage];
		} @catch (NSException *e) {
			NSLog(@"Exception:%@");
		}
	}
	[pool release];
	exit(0);
}

@implementation SendMail

@synthesize from;
@synthesize to;
@synthesize cc;
@synthesize bcc;
@synthesize subject;
@synthesize attachment;
@synthesize body;
@synthesize sendMsg;
@synthesize visible;


- (void)sendEmailMessage {
	
	NSError *error = nil;
	
	// from, body and subject can't be nil:
	if ( self.from == nil )
		self.from = [NSString stringWithString:@""];
	if ( self.subject == nil )
		self.subject = [NSString stringWithString:@""];
	if ( self.body == nil )
		self.body = [NSString stringWithString:@""];
		
	// Create a new application object for Mail:
    MLApplication *mail = [[MLApplication alloc] initWithBundleID: @"com.apple.mail"];
	
	
	// Create a new message and set some values:
	MLMakeCommand *makeCmd = [[[mail make] new_: [MLConstant outgoingMessage]] 
							  withProperties: [NSDictionary dictionaryWithObjectsAndKeys: 
											   self.from, [MLConstant sender],
											   self.subject, [MLConstant subject],
											   self.body, [MLConstant content],
											   nil]];
	MLReference *msg = [makeCmd sendWithError: &error];
	if (!msg) goto finish;
	
	// Show message or not:
	if ( visible ) 
		[[[[msg visible] set] to: ASTrue] send];
	
	// Add "to" addresses:
	for	( NSString* item in [self.to componentsSeparatedByString: @";"] ) {
		
		makeCmd = [[[[mail make] new_: [MLConstant toRecipient]] 
					at: [[msg toRecipients] end]]
				   withProperties: [NSDictionary
									dictionaryWithObject: item 
									forKey: [MLConstant address]]];
		if (![makeCmd sendWithError: &error]) goto finish;
		
	}
    // Add "cc" addresses:
	for	( NSString* item in [self.cc componentsSeparatedByString: @";"] ) {
		
		makeCmd = [[[[mail make] new_: [MLConstant ccRecipient]] 
					at: [[msg ccRecipients] end]]
				   withProperties: [NSDictionary
									dictionaryWithObject: item 
									forKey: [MLConstant address]]];
		if (![makeCmd sendWithError: &error]) goto finish;
		
	}
    // Add "bcc" addresses:
	for	( NSString* item in [self.bcc componentsSeparatedByString: @";"] ) {
		
		makeCmd = [[[[mail make] new_: [MLConstant bccRecipient]] 
					at: [[msg bccRecipients] end]]
				   withProperties: [NSDictionary
									dictionaryWithObject: item 
									forKey: [MLConstant address]]];
		if (![makeCmd sendWithError: &error]) goto finish;
		
	}
    // Add attachments:
	for	( NSString* path in [self.attachment componentsSeparatedByString: @"\n"] ) {
		if ( [path length] > 0 ) {
			
			// Create attachment:
			makeCmd = [[[[mail make] new_: [MLConstant attachment]]
						at: [[[msg content] paragraphs] end]]
					   withProperties: [NSDictionary
										dictionaryWithObject: path
										forKey: [MLConstant fileName]]];
			// Try to add it to the message:
			if (![makeCmd sendWithError: &error]) {
				NSLog(@"Couldn't attach attachment: %@", [error localizedDescription]);
				goto finish;
			}
		}
	}
	
	// Send message:
	if ( sendMsg )
		[[msg send_] sendWithError: &error];
	
finish:
	if (error) NSLog(@"An error occurred:\n%@\n\n%@", error, [error userInfo]);
	[mail release];
}

@end

@implementation QueryFactory

- (void)searchAndPrint: (NSString *)theStr {
	NSString * text1, * text2;
	NSInteger index =  0, index2;
	ABAddressBook * theAddressBook = [ABAddressBook sharedAddressBook];
	ABPerson * contact;
	NSString     * delimiter = [NSString stringWithString:@"\n"];
	NSMutableString * fullName = @"";
	
	// Is there a space or comma in the string?
	if ([theStr rangeOfString:@", "].location != NSNotFound) {
		index = [theStr rangeOfString:@", "].location;
		index2 = index + 2;
	} else if ([theStr rangeOfString:@","].location != NSNotFound) {
		index = [theStr rangeOfString:@","].location;
		index2 = index + 1;
	} else if ([theStr rangeOfString:@" "].location != NSNotFound) {
			index = [theStr rangeOfString:@" "].location;
			index2 = index + 1;
	}
	
	if (index > 0) {
		// If so, split the string in two:
		text1 = [theStr substringToIndex:index];
		text2 = [theStr substringFromIndex:index2];
	} else {
		// Or not...
		text1 = theStr;
	}
	
	// Prepare the search query:
	firstName = [ABPerson
				 searchElementForProperty: kABFirstNameProperty
				 label: nil
				 key: nil
				 value: text1
				 comparison: kABPrefixMatchCaseInsensitive];
	
	firstNamePhonetic = [ABPerson
						 searchElementForProperty: kABFirstNamePhoneticProperty
						 label: nil
						 key: nil
						 value: text1
						 comparison: kABPrefixMatchCaseInsensitive];
	
	lastName = [ABPerson
				searchElementForProperty: kABLastNameProperty
				label: nil
				key: nil
				value: text1
				comparison: kABPrefixMatchCaseInsensitive];
	
	lastNamePhonetic = [ABPerson
						searchElementForProperty: kABLastNamePhoneticProperty
						label: nil
						key: nil
						value: text1
						comparison: kABPrefixMatchCaseInsensitive];
	
	maidenName = [ABPerson
				  searchElementForProperty: kABMaidenNameProperty
				  label: nil
				  key: nil
				  value: text1
				  comparison: kABPrefixMatchCaseInsensitive];
	
	middleName = [ABPerson
				  searchElementForProperty: kABMiddleNameProperty
				  label: nil
				  key: nil
				  value: text1
				  comparison: kABPrefixMatchCaseInsensitive];
	
	middleNamePhonetic = [ABPerson
						  searchElementForProperty: kABMiddleNamePhoneticProperty
						  label: nil
						  key: nil
						  value: text1
						  comparison: kABPrefixMatchCaseInsensitive];
	
	nickName = [ABPerson
				searchElementForProperty: kABNicknameProperty
				label: nil
				key: nil
				value: text1
				comparison: kABPrefixMatchCaseInsensitive];
	
	email = [ABPerson
			 searchElementForProperty: kABEmailProperty
			 label: nil
			 key: nil
			 value: text1
			 comparison: kABPrefixMatchCaseInsensitive];
	
	NSMutableArray * theArray = [NSArray arrayWithObjects:
								 firstName,
								 firstNamePhonetic,
								 lastName,
								 lastNamePhonetic,
								 maidenName,
								 middleName,
								 middleNamePhonetic,
								 nickName,
								 email,
								 nil];
	if (index) {
		// If the string was split, use the second part:
		
		firstName = [ABPerson
					 searchElementForProperty: kABFirstNameProperty
					 label: nil
					 key: nil
					 value: text1
					 comparison: kABPrefixMatchCaseInsensitive];
		
		firstNamePhonetic = [ABPerson
							 searchElementForProperty: kABFirstNamePhoneticProperty
							 label: nil
							 key: nil
							 value: text1
							 comparison: kABPrefixMatchCaseInsensitive];
		
		lastName = [ABPerson
					searchElementForProperty: kABLastNameProperty
					label: nil
					key: nil
					value: text1
					comparison: kABPrefixMatchCaseInsensitive];
		
		lastNamePhonetic = [ABPerson
							searchElementForProperty: kABLastNamePhoneticProperty
							label: nil
							key: nil
							value: text1
							comparison: kABPrefixMatchCaseInsensitive];
		
		maidenName = [ABPerson
					  searchElementForProperty: kABMaidenNameProperty
					  label: nil
					  key: nil
					  value: text1
					  comparison: kABPrefixMatchCaseInsensitive];
		
		middleName = [ABPerson
					  searchElementForProperty: kABMiddleNameProperty
					  label: nil
					  key: nil
					  value: text1
					  comparison: kABPrefixMatchCaseInsensitive];
		
		middleNamePhonetic = [ABPerson
							  searchElementForProperty: kABMiddleNamePhoneticProperty
							  label: nil
							  key: nil
							  value: text1
							  comparison: kABPrefixMatchCaseInsensitive];
		
		nickName = [ABPerson
					searchElementForProperty: kABNicknameProperty
					label: nil
					key: nil
					value: text1
					comparison: kABPrefixMatchCaseInsensitive];
		
		email = [ABPerson
				 searchElementForProperty: kABEmailProperty
				 label: nil
				 key: nil
				 value: text1
				 comparison: kABPrefixMatchCaseInsensitive];
		
		[theArray addObjectsFromArray: [NSArray arrayWithObjects:
										firstName2,
										firstNamePhonetic2,
										lastName2,
										lastNamePhonetic2,
										maidenName2,
										middleName2,
										middleNamePhonetic2,
										nickName2,
										email2,
										nil]];
	}
	// Set search criteria:
	theQuery = [ABSearchElement
				searchElementForConjunction:kABSearchOr
				children: theArray];
	// Search:
	NSArray * theResults = [theAddressBook recordsMatchingSearchElement:theQuery];
	
	// Print results:
	for (contact in theResults) {
		NSString     * first	= [contact valueForProperty:kABFirstNameProperty];
		NSString     * last		= [contact valueForProperty:kABLastNameProperty];
		NSString     * nick		= [contact valueForProperty:kABNicknameProperty];
		NSString     * company  = [contact valueForProperty:kABOrganizationProperty];
		ABMultiValue * emailsList	= [contact valueForProperty:kABEmailProperty];
		
		// Don't show empty values:
		if ( first && last ) {
			fullName = [NSString stringWithFormat:@"%@ %@ ", first, last];
		} else if ( first ) {
			fullName = [NSString stringWithFormat:@"%@ ", first];
		} else if ( last ) {
			fullName = [NSString stringWithFormat:@"%@ ", last];
		} else if ( company ) {
			fullName = [NSString stringWithFormat:@"%@ ", company];
		} else if ( nick ) {
			fullName = [NSString stringWithFormat:@"%@ %@ ", nick];
		} else {
			fullName = [NSString stringWithString:@""];
		}
		
		// Only results with emails:
		if ( emailsList != nil ) {
			int i, emailsNumber = [emailsList count];
			for ( i = 0; i < emailsNumber; i++ ) {
				NSString * thisEmail = [emailsList valueAtIndex: i];
				printf("%s<%s>%s", [fullName UTF8String], [thisEmail UTF8String], [delimiter UTF8String]);
			}
		}
	}
}

@end

