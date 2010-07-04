package fl.data {
	
	dynamic public class SimpleDataProvider extends Object {
		
		public var dataProvider:Array;
		
		public function SimpleDataProvider() {
			dataProvider = [];
		}
		
		public function addItem(item:Object):void {
			dataProvider.push(item);
		}
		
		public function getItemAt(index:uint):Object {
			return dataProvider[index];
		}
		
		public function get length():uint {
			return dataProvider.length;
		}
		
		public function toString():String {
			return "[SimpleDataProvider (" + dataProvider.join(",") + ")]";
		}
		
	}
	
}