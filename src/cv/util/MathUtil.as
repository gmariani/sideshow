
package cv.util {

	import flash.geom.Point;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * A collection of useful math related functions. Some are actually replacements for built in Math
	 * class methods becuase they are more effecient than the default.
     *
     * @langversion 3.0
     * @playerversion Flash 9
	 */
	public class MathUtil {
		
		protected static const _RAD2DEG:Number = 180 / Math.PI;
		protected static const _DEG2RAD:Number = Math.PI / 180;
		
		public static function addLeadingZero(value:Number):String {
			return (value < 10) ? '0' + value : value.toString();
		}
		
		/**
		 * A more effecient way of calculating the absolute value of a number.
		 * 
		 * @param	value<Number> The number to use
		 * @return The absolute value of the given number
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function abs(value:Number):Number {
			if (value < 0) value = -value;
			return value;
		}
		
		/**
		 * A more effecient way of calculating the ceiling value of a number.
		 * 
		 * @param	value<Number> The number to use
		 * @return The ceiling value of the given number
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function ceil(value:Number):int {
			return int(value + 1) + (value >> 31);
		}
		
		/**
		 * Ensures a given number is between the minimum and maximum limits. Useful
		 * to keep a value between 0 and 1 for instance.
		 * 
		 * @param	min<Number> The lower limit of the range.
		 * @param	max<Number> The upper limit of the range.
		 * @param	value<Number> The number to test
		 * @return A number between the minimum and maximum limits.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function clamp(min:Number, max:Number, value:Number):Number {
			if(value < min) return min;
			if(value > max) return max;
			return value;
		}
		
		/**
		 * A more effecient way of calculating the floor value of a number.
		 * 
		 * @param	value<Number> The number to use
		 * @return The floored value of the given number
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function floor(value:Number):int { return value >> 0; }
		
		/**
		 * Converts radians to degrees.
		 * 
		 * @param	n<Number> The radian to convert
		 * @return The equivalent degrees.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function radiansToDegrees(n:Number):Number { return n * _RAD2DEG }
		
		/**
		 * Converts degrees to radians.
		 * 
		 * @param	n<Number> The degree to convert
		 * @return The equivalent radians.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function degreesToRadians(n:Number):Number { return n * _DEG2RAD }
		
		public static function interpolate(amount:Number, minimum:Number, maximum:Number):Number {
			return minimum + (maximum - minimum) * amount;
		}
		
		/**
		 * Used to determine if a number is a prime number or not.
		 * 
		 * @param	n<Number> The number to test.
		 * @return True or false whether the number is prime.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function isPrime(n:Number):Boolean {
			if (n > 2 && n % 2 == 0) return false;
			var l:Number = Math.sqrt(n);
			for (var i:uint = 3; i <= l; i += 2) {
				if (n % i == 0) return false;
			}
			return true;
		}
		
		/**
		 * Return a random number between a range of numbers
		 * 
		 * @param	min<Number> The minimum number in the range
		 * @param	max<Number> The maximum number in the range
		 * @return A random number between the two numbers given.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function randomRange(min:Number, max:Number):Number {
			return Math.random() * (max - min) + min;
		}
		
		/**
		 * Converts a large number intro a comma delimited string. From
		 * 1000 to 1,000.
		 * 
		 * @param	n<Number> The number to convert.
		 * @return The converted number.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function thousandSeparator(n:Number):String {
			var arr:Array = n.toString().split('.');
			var str:String = arr[0];
			var strReturn:String = "";
			var q:uint = 0;
			
			for (var k:int = str.length - 1; k >= 0; k--) {  
				if(q % 3 == 0 && q != 0) strReturn = ',' + strReturn;
				strReturn = str.charAt(k) + strReturn;
				q++;
			}
			
			if(arr[1]) strReturn += '.' + arr[1];
			return strReturn;
		}
	}
}