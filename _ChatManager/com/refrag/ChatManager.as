package com.refrag
{
	import flash.utils.ByteArray;
	
	import org.flixel.FlxG;
	//The convo manager handles the XML importing and generates discreet conversations to handle each xml file
	public class ChatManager
	{
		private static var convoTable:Array;
		
		private static var xml:XML = new XML();
		
		public static var actors:Array;
		
		public function ChatManager()
		{
		}
		
		public static function initialize (b:ByteArray):void
		{
			
			convoTable = new Array();
			actors = new Array();
			xml = byteArray2XML(b);
			setupActors();
			
			var tmpXML = xml.Assets..Conversation[0];
			convoTable.push(new Conversation(tmpXML));
			
		}

		public static function byteArray2XML(b:ByteArray):XML
		{
			var ba:ByteArray = b;
			
			return new XML(ba.readUTFBytes(ba.length));
			
		}
		
		private static function setupActors():void
		{
			//Create a blank actor at ID 0 since Chat Mapper starts IDs at "1"
			actors.push("Sir Blank-a-lot");
			
			//Populate the array with actor names
			var i:int=0;		
			for each (var e:XML in xml..Actor){
				actors.push(e..Field.(Title=="Name").Value.toString());
				i++;
			}
			
			
		}
		
		public static function getActor(i:int):String
		{
			return (actors[i]);
		}
		
		public static function getCurrentConvo():Conversation
		{
			return(convoTable[0]);
		}
		
	}
}