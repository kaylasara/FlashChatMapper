package com.refrag
{
	import org.flixel.*;
	
	//The Conversation class holds and handles the xml for each discreet conversation chain including tweets and actions
	
	public class Conversation
	{
		private var xml:XML;
		
		//Store the currents for quick accessing
		public var id:int=0;
		public var nextId:int=0;
		public var actor:String;
		public var conversant:String;
		public var text:String;
		
		public var isGroup:Boolean;
		public var replyIDs:Array;
		public var replyText:Array;
		
		private var endPoint:Boolean = false;
		public var dead=false;
		
		public function Conversation(x:XML)
		{
			xml=x;
			parseNode(1);

		}
		
		public function gotoID(i:int=0):void
		{
			if (!endPoint) {
				parseNode(i);	
			}
			else{
				killMe();
			}
		}
		
		public function getReplyText():Array
		{
			if (isGroup){
				return replyText;
			}
			else{
				trace("Conversation Warning: No replies. Not a decision point.");
				return null;
			}
		}
		
		private function parseNode(i:int):void
		{
			replyIDs = new Array();
			replyText = new Array();
			
			//Shorten the syntax a bit for better reading
			var x = xml..DialogEntry.(@ID==i);
			
			//Handle an empty node | Auto move to the next node if we find an empty node (with no dialog text)
			//Is there any dialog text at this node?
			if (x..Field.(Title=="Dialogue Text").Value.toString()== ""){
				//If not, is there a node we can go to next?
				if (x..Link.@DestinationDialogID.toString()==""){
					//If not, I think the conversation is over we should do something
				}else{
					//Otherwise, let's follow to the next node and see what's going on
					i = x..Link.@DestinationDialogID.toString();
					x = xml..DialogEntry.(@ID==i);
				}
			}
			
			//Let's pretend we aren't a decision point!
			isGroup=false;
			
			//Who is speaking?
			actor=ChatManager.getActor(x..Field.(Title=="Actor").Value.toString());
					
			//Who is being spoken to?
			conversant=ChatManager.getActor(x..Field.(Title=="Conversant").Value.toString());
			
			//What is the dialog text?
			text=x..Field.(Title=="Dialogue Text").Value.toString();
							
			//What's the next node ID?
			nextId=x..Link.@DestinationDialogID.toString();
			
			if ((x..Link.@DestinationDialogID.toString())=="") endPoint=true;
				
			//Now we check to see if the next node is a decision point (which we need to resolve now)
			if (xml..DialogEntry.(@ID==nextId).@IsGroup=="true"){
				
				//Shorten the XML syntax to that decision node
				x=xml..DialogEntry.(@ID==nextId);
				//Handle Decision Point
				
				isGroup=true;
				nextId=null;
				//Create an array of reply IDs
				var j:int=0;		
				for each (var e:XML in x..Link){
					replyIDs.push(e.@DestinationDialogID.toString());
					replyText.push(xml..DialogEntry.(@ID==replyIDs[j])..Field.(Title=="Menu Text").Value.toString());
					j++;
				}
				
				
			}
		}
		
		public function reset()
		{
			dead=false;
			endPoint=false;
			gotoID(0);
		}
		
		private function killMe()
		{
			dead=true;
			id=0;
			nextId=0;
			actor = "";
			conversant = "";
			text = "";
			
			isGroup = false;;
			replyIDs = new Array();
			replyText = new Array();
		}
	}
}