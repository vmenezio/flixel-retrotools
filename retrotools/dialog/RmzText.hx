package retrotools.dialog;

import flixel.addons.text.FlxTypeText;

/**
 * ...
 * @author Vinícius Menézio
 */
class RmzText extends FlxTypeText
{

	public function new(X:Float, Y:Float, Width:Int, Text:String, Size:Int=8, EmbeddedFont:Bool=true) 
	{
		super(X, Y, Width, Text, Size, EmbeddedFont);
		
	}

	public function getLineNumber():Int {
		return _textField.numLines;
		//_textField.getLineText();
	}
	
}