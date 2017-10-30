package com.gamebook.utils {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    
    /**
     * ..
     * @author Matt Bolt, Electrotank© 2009
     */
    public class TileAssetsUtil {
        
        /**
         * @private
         * legal tile
         */
        [Embed(source='/assets/tiles/green-up.png')]
        private static var LegalTileBitmap:Class;
        
        /**
         * @private
         * illegal tile
         */
        [Embed(source='/assets/tiles/red-up.png')]
        private static var IllegalTileBitmap:Class;
        
        /**
         * This constant represents a legal tile in user
         * homes.
         */
        public static const LEGAL_TILE_DATA:BitmapData = Bitmap(new LegalTileBitmap()).bitmapData;
        
        /**
         * This constant represents an illegal tile in user
         * homes.
         */
        public static const ILLEGAL_TILE_DATA:BitmapData = Bitmap(new IllegalTileBitmap()).bitmapData;
        
    }
    
}