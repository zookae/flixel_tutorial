package ;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxAngle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.system.FlxSound;
import flixel.util.FlxDestroyUtil;

class Player extends FlxSprite {
	public var speed:Float = 200;
	private var _sndStep:FlxSound;

	public function new(X:Float=0, Y:Float=0) {
		super(X, Y);
		//makeGraphic(16, 16, FlxColor.BLUE);
		loadGraphic("assets/images/player.png", true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);

		animation.add("lr", [3, 4, 3, 5], 6, false);
		animation.add("u", [6, 7, 6, 8], 6, false);
		animation.add("d", [0, 1, 0, 2], 6, false);
		_sndStep = FlxG.sound.load("assets/sounds/step.wav");

		drag.x = drag.y = 1600;

		// adjust player size to be 8 x 14; offset center to 4, 2
		// helps fit through narrow corridors	
		setSize(8, 14);
		offset.set(4, 2);
	}

	private function movement():Void {
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;

		_up = FlxG.keys.anyPressed(["UP", "W"]);
		_down = FlxG.keys.anyPressed(["DOWN", "S"]);
		_left = FlxG.keys.anyPressed(["LEFT", "A"]);
		_right = FlxG.keys.anyPressed(["RIGHT", "D"]);

		// cancel identical keys
		if (_up && _down) {
			_up = _down = false;
		}
		if (_left && _right) {
			_left = _right = false;
		}

		if (_up || _down || _left || _right) {

			var mA:Float = 0;
			if (_up) {
				mA = -90;
				if (_left) {
					mA -= 45;
				} else if (_right) {
					mA += 45;
				}
				facing = FlxObject.UP;
			} else if (_down) {
				mA = 90;
				if (_left) {
					mA += 45;
				} else if (_right) {
					mA -= 45;
				}
				facing = FlxObject.DOWN;
			} else if (_left) {
				mA = 180;
				facing = FlxObject.LEFT;
			} else if (_right) {
				mA = 0;
				facing = FlxObject.RIGHT;
			}

			FlxAngle.rotatePoint(speed, 0, 0, 0, mA, velocity);

			if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE) {
				_sndStep.play();
				switch (facing) {
					case FlxObject.LEFT, FlxObject.RIGHT:
						animation.play("lr");
					case FlxObject.UP:
						animation.play("u");
					case FlxObject.DOWN:
						animation.play("d");
				}
			}
		}
	}

	override public function update():Void {
		movement();
		super.update();
	}

	override public function destroy():Void{
		super.destroy();
		_sndStep = FlxDestroyUtil.destroy(_sndStep);
	}

}