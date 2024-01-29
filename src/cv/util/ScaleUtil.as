
package cv.util {
	
	import flash.geom.Rectangle;
	
	public class ScaleUtil {
		
		/**
		 * Determines the ratio of height to width.
		 * 
		 * @param item The item to scale
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function getHeightToWidth(item:*):Number {
			return item.height / item.width;
		}
		
		/**
		 * Determines the ratio of width to height.
		 * 
		 * @param item The item to scale
		 */
		public static function getWidthToHeight(item:*):Number {
			return item.width / item.height;
		}
		
		/**
		 * Scales the height of an area while preserving aspect ratio.
		 * 
		 * @param item The item to scale
		 * @param width: The new width of the item.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function scaleHeight(item:*, width:Number):void {
			var ratio:Number = ScaleUtil.getHeightToWidth(item);
			item.width  = width;
			item.height = width * ratio;
		}
		
		/**
		 * Resizes an item to the specified ratios. This is useful for aspect ratios such as 16:9.
		 * 
		 * @param	item The item to scale
		 * @param	ratioWidth The ratio to for the width
		 * @param	ratioHeight	The ratio for the height
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function toAspectRatio(item:*, ratioWidth:Number, ratioHeight:Number):void {
			item.width *= ((ratioWidth * item.height) / (item.width * ratioHeight));
			item.height *= ((item.width * ratioHeight) / (ratioWidth * item.height));
		}
		
		/**
		 * Resizes an item to the maximum size of a bounding area without exceeding while preserving aspect ratio.
		 * 
		 * @param item The item to scale
		 * @param bounds The area the item needs to fit within. The Rectangle's x and y values are ignored.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function toFit(item:*, bounds:Rectangle):void {
			ScaleUtil.scaleHeight(item, bounds.width);
			if (item.height > bounds.height) ScaleUtil.scaleWidth(item, bounds.height);
		}
		
		/**
		 * Scales the width of an area while preserving aspect ratio.
		 * 
		 * @param item The item to scale
		 * @param height The new height of the item.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function scaleWidth(item:*, height:Number):void {
			var ratio:Number = ScaleUtil.getWidthToHeight(item);
			item.width  = height * ratio;
			item.height = height;
		}
	}
}