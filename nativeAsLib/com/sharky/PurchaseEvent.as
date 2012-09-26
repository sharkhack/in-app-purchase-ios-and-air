package com.sharky
{
	/*
	 * in-app-purchase-ios-and-air
	 * https://github.com/sharkhack/
	 *
	 * Copyright (c) 2012 Azer Bulbul
	 * Licensed under the MIT license.
	 * https://github.com/sharkhack/in-app-purchase-ios-and-air/LICENSE-MIT
	 */

	import flash.events.Event;
	
	public class PurchaseEvent extends Event
	{
		
		public static const PRODUCTS_RECEIVED:String = "productsReceived";
		public static const UPDATED_TRANSACTIONS:String = "updatedTransactions";
		public static const REMOVED_TRANSACTIONS:String = "removedTransactions";
		public static const RESTORE_FAILED:String = "restoreFailed";
		public static const RESTORE_COMPLETE:String = "restoreComplete";
		
		private var _products:Array = null;
		private var _invalidIdentifiers:Array = null;
		private var _transactions:Array = null;
		private var _error:String = "";
		
		public function PurchaseEvent(type:String,prods:Array,invalids:Array,trans:Array,e:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_products = prods;
			_invalidIdentifiers = invalids;
			_transactions = trans;
			_error = e;
		}
		
		public function get products():Array{ 
			return _products;
		}
		
		public function get invalidIdentifiers():Array{
			return _invalidIdentifiers;
		}
		
		public function get transactions():Array{
			return _transactions;
		}
		
		public function get error():String{
			return _error;
		}
		
		public override function clone():Event{
			return new PurchaseEvent(type,_products,_invalidIdentifiers,_transactions,_error,bubbles,cancelable); 
		}
	}
}
