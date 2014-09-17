package retrotools.dialog;

import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.system.FlxSound;

/**
 * ...
 * @author Vinícius Menézio
 */
class RmzText extends FlxTypeText
{
	
	private var originalText:String;
	
	private var maxLines:Int = 0;
	private var nextText:String = "";

	public function new( x:Float, y:Float, width:Int, text:String, size:Int=8, embeddedFont:Bool=true ) {
		super( x, y, width, text, size, embeddedFont );
		originalText = text;
	}
	
	private function insertLineBreaks():Void {
		var lines:Array<String> = new Array();
		var helperTextArea:FlxText;
		//var sourceText:String = originalText + "\n*";
		var sourceText:String = originalText;
		//var restText:String = originalText;
		var currentLine:String;
		helperTextArea = new FlxText(0, 0, this.fieldWidth, sourceText, Std.int(this.size), this.embedded);
		//var i = 0;
		//while ( i < sourceText.length ) {
			//if ( helperTextArea._textField.getLineIndexOfChar( i ) > 0 ) {
				//lines.push( sourceText.substr( 0, i-1 ) );
				//sourceText = sourceText.substr( i );
				//helperTextArea.text = sourceText;
				//i = 0;
			//}
			//i++;
		//}
		while ( sourceText.length > 0 ) {
			currentLine = StringTools.replace( helperTextArea._textField.getLineText(0), "\r", "\n" );
			sourceText = StringTools.replace( sourceText, currentLine, "" );
			helperTextArea.text = sourceText;
			if ( StringTools.endsWith( currentLine, "\n" ) )
				currentLine = currentLine.substring( 0, currentLine.length - 1);
			lines.push( currentLine );
		}
		_finalText = "";
		nextText = "";
		if ( maxLines == 0 ) {
			while ( lines.length > 0 ) {
				_finalText += lines.splice(0, 1)[0] + "\n";
			}
		} else {
			var j = 0;
			while ( j < maxLines && lines.length > 0 ) {
				_finalText += lines.splice(0, 1)[0] + "\n";
				j++;
			}
			while ( lines.length > 0 ) {
				nextText += lines.splice(0, 1)[0] + "\n";
			}
		}
		if ( StringTools.endsWith( _finalText, "\n" ) )
			_finalText = _finalText.substring( 0, _finalText.length - 1);
		if ( StringTools.endsWith( nextText, "\n" ) )
			nextText = nextText.substring( 0, nextText.length - 1);
	}
	
	public function getNextText():String {
		return nextText;
	}
	
	public function setMaxLines( maxLines:Int ):Void {
		this.maxLines = maxLines;
		insertLineBreaks();
	}
	
	override public function resetText( newText:String ):Void {
		super.resetText(newText);
		originalText = newText;
		insertLineBreaks();
	}
	
	override public function start( ?delay:Float, forceRestart:Bool = false, autoErase:Bool = false, ?sound:FlxSound, ?skipKeys:Array<String>, ?callback:Dynamic, ?params:Array<Dynamic>):Void {
		if ( maxLines < 0 )
			throw "maxLines must be greater than or equal to zero.";
		super.start( delay, forceRestart, autoErase, sound, skipKeys, callback, params );
	}
	
}