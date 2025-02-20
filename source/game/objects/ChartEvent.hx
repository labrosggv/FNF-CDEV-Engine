package game.objects;

import lime.app.Application;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.util.FlxAxes;
import flixel.addons.text.FlxTypeText;
import haxe.Json;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.sound.FlxSound;
import game.cdev.script.ScriptSupport;
import openfl.Assets;
import flixel.system.FlxAssets;
import meta.modding.ModPaths;
import flixel.FlxG;
import openfl.display.BitmapData;
import meta.states.PlayState;
import haxe.io.Path;
import game.cdev.script.HScript;
import game.cdev.CDevConfig;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef SongEvent =
{
	var name:String; // dumb
}

class ChartEvent extends FlxSprite
{
	public var EVENT_NAME:String = '';
	public var time:Float = 0;
	public var data:Int = 0;

	public var value1:String = '';
	public var value2:String = '';

	public var script:HScript = null;
	public var mod:String = '';

	// put your codes here incase you want to hardcode your song events
	public static var builtInEvents:Array<Dynamic> = [
		[
			'Add Camera Zoom',
			"Change how much does the camera zoom should\nbe added (like M.I.L.F's \"banger\" part)\n\n Value 1: Camera to zoom (gameCam or hudCam)\nValue 2: Zoom to add to the camera (Float)"
		],
		[
			'Force Camera Position',
			"Move the camera position to a specific position\n(The camera position will be locked to your position values, leave the value 1 and 2 blank to unlock the camera)\n\nValue 1: Position X\nValue 2: Position Y"
		],
		[
			'Play Animation',
			"Playing an animation for a character\n\nValue 1: Character (dad, gf, bf)\nValue 2: Animation prefix to play"
		],
		[
			'Change Scroll Speed',
			"Change your song scroll speed\n\nValue 1: New Scroll Speed\nValue 2: Leave it blank"
		],
		[
			'Screen Shake',
			'Shaking a camera object for specific seconds.\n\nValue 1: Shake Properties\nValue 2: Camera Object (gameCam or hudCam)\n\nUsage Example:\nValue 1: 1, 0.05 (Duration, Intensity)\nValue 2: gameCam (this will shake the main camera)'
		],
		[
			"Play Sound",
			"Just like it's name, it plays a sound.\n\nValue 1: Sound File Name\nValue 2: Volume ranging from 0 to 1 (Default is 1)"
		],
		[
			"Idle Suffix",
			"Whether to set a specified suffix after the idle animation name.\nThe animation will be called when Alternate Animation is true.\n\nValue 1: Character to set the prefix (dad, bf, gf)\nValue 2: New Suffix (Default is \"-alt\")"
		]
	];

	public function new(strumTime:Float, noteData:Int, ?charting:Bool = false)
	{
		this.time = strumTime;
		this.data = noteData;
		super(x, y);
		if (charting)
			loadGraphic(Paths.image('eventIcon', "shared"));
	}

	public static function getEventNames():Array<String>
	{
		var eventNames:Array<String> = [];
		#if sys
		var path:Array<String> = [];
		var canDoShit = false;
		if (FileSystem.exists(Paths.modFolders("events/"))){ //support for older cdev engine version
			path = FileSystem.readDirectory(Paths.modFolders("events/"));
			canDoShit = true;
		}
		if (canDoShit){
			if (path.length >= 0)
				{
					for (i in 0...path.length)
					{
						var event:String = path[i];
						if (event.endsWith(".txt"))
						{
							event = event.substr(0, event.length - 4);
							eventNames.push(event);
							trace("loaded " + event);
						}
					}
				}
				else
				{
					return ["No Events Found."];
				}
		} else{
			return ["No Events Found."];
		}
		#else
		trace("This is not a sys target, could not get event names.");
		return ["No Events Found."];
		#end

		return eventNames;
	}

	// the variable "event" is the event's name.
	public static function getEventDescription(event:String = ""):String
	{
		var eventDescription:String = "";
		#if sys
		var path:Array<String> = [];
		var canDoShit = false;
		if (FileSystem.exists(Paths.modFolders("events/"))){ //support for older cdev engine version
			path = FileSystem.readDirectory(Paths.modFolders("events/"));
			canDoShit = true;
		}
		if (canDoShit){
			if (path.length >= 0)
			{
				for (i in 0...path.length)
				{
					var file:String = path[i];
					var desc:String = "";
					if (file.substr(0, file.length - 4) == event)
					{
						if (file.endsWith(".txt"))
						{
							desc = File.getContent(Paths.modFolders("events/" + file));
							eventDescription = desc;
							// trace("desc " + event); nah man
						}
					}
				}
			}
		}
		#else
		trace("This is not a sys target, could not get event description for "+event+".");
		#end
		return eventDescription;
	}
}