package jp.nyatla.nyartoolkit.as3.detector
{
	import jp.nyatla.nyartoolkit.as3.NyARException;
	import jp.nyatla.nyartoolkit.as3.core.NyARCode;
	import jp.nyatla.nyartoolkit.as3.core.match.NyARMatchPattDeviationColorData;
	import jp.nyatla.nyartoolkit.as3.core.match.NyARMatchPattResult;
	import jp.nyatla.nyartoolkit.as3.core.match.NyARMatchPatt_Color_WITHOUT_PCA;
	import jp.nyatla.nyartoolkit.as3.core.param.NyARParam;
	import jp.nyatla.nyartoolkit.as3.core.pickup.INyARColorPatt;
	import jp.nyatla.nyartoolkit.as3.core.raster.rgb.INyARRgbRaster;
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.NyARCoord2Linear;
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.NyARSquare;
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.NyARSquareContourDetector;
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.NyARSquareContourDetector_IDetectMarkerCallback;
	import jp.nyatla.nyartoolkit.as3.core.types.NyARIntPoint2d;
	import jp.nyatla.nyartoolkit.as3.core.types.NyARLinear;

	internal class NyARDetectSquareCB implements NyARSquareContourDetector_IDetectMarkerCallback
	{
		//公開プロパティ
		public var result_stack:NyARDetectMarkerResultStack=new NyARDetectMarkerResultStack(NyARDetectMarker.AR_SQUARE_MAX);
		//参照インスタンス
		public var _ref_raster:INyARRgbRaster;
		//所有インスタンス
		private var _inst_patt:INyARColorPatt;
		private var _deviation_data:NyARMatchPattDeviationColorData;
		private var _match_patt:Vector.<NyARMatchPatt_Color_WITHOUT_PCA>;
		private var __detectMarkerLite_mr:NyARMatchPattResult=new NyARMatchPattResult();
		private var _coordline:NyARCoord2Linear;
		
		public function NyARDetectSquareCB(i_inst_patt:INyARColorPatt, i_ref_code:Vector.<NyARCode>, i_num_of_code:int, i_param:NyARParam)
		{
			var cw:int = i_ref_code[0].getWidth();
			var ch:int = i_ref_code[0].getHeight();
	
			this._inst_patt=i_inst_patt;
			this._coordline=new NyARCoord2Linear(i_param.getScreenSize(),i_param.getDistortionFactor());
			this._deviation_data=new NyARMatchPattDeviationColorData(cw,ch);
	
			//NyARMatchPatt_Color_WITHOUT_PCA[]の作成
			this._match_patt=new Vector.<NyARMatchPatt_Color_WITHOUT_PCA>(i_num_of_code);
			this._match_patt[0]=new NyARMatchPatt_Color_WITHOUT_PCA(i_ref_code[0]);
			for (var i:int = 1; i < i_num_of_code; i++){
				//解像度チェック
				if (cw != i_ref_code[i].getWidth() || ch != i_ref_code[i].getHeight()) {
					throw new NyARException();
				}
				this._match_patt[i]=new NyARMatchPatt_Color_WITHOUT_PCA(i_ref_code[i]);
			}
			return;
		}
		private var __tmp_vertex:Vector.<NyARIntPoint2d>=NyARIntPoint2d.createArray(4);
		/**
		 * 矩形が見付かるたびに呼び出されます。
		 * 発見した矩形のパターンを検査して、方位を考慮した頂点データを確保します。
		 */
		public function onSquareDetect(i_sender:NyARSquareContourDetector,i_coordx:Vector.<int>,i_coordy:Vector.<int>,i_coor_num:int ,i_vertex_index:Vector.<int>):void
		{
			var mr:NyARMatchPattResult=this.__detectMarkerLite_mr;
			//輪郭座標から頂点リストに変換
			var vertex:Vector.<NyARIntPoint2d>=this.__tmp_vertex;
			vertex[0].x=i_coordx[i_vertex_index[0]];
			vertex[0].y=i_coordy[i_vertex_index[0]];
			vertex[1].x=i_coordx[i_vertex_index[1]];
			vertex[1].y=i_coordy[i_vertex_index[1]];
			vertex[2].x=i_coordx[i_vertex_index[2]];
			vertex[2].y=i_coordy[i_vertex_index[2]];
			vertex[3].x=i_coordx[i_vertex_index[3]];
			vertex[3].y=i_coordy[i_vertex_index[3]];
		
			//画像を取得
			if (!this._inst_patt.pickFromRaster(this._ref_raster,vertex)){
				return;
			}
			//取得パターンをカラー差分データに変換して評価する。
			this._deviation_data.setRaster(this._inst_patt);
	
			//最も一致するパターンを割り当てる。
			var square_index:int,direction:int;
			var confidence:Number;
			this._match_patt[0].evaluate(this._deviation_data,mr);
			square_index=0;
			direction=mr.direction;
			confidence=mr.confidence;
			//2番目以降
			var i:int;
			for(i=1;i<this._match_patt.length;i++){
				this._match_patt[i].evaluate(this._deviation_data,mr);
				if (confidence > mr.confidence) {
					continue;
				}
				// もっと一致するマーカーがあったぽい
				square_index = i;
				direction = mr.direction;
				confidence = mr.confidence;
			}
			//最も一致したマーカ情報を、この矩形の情報として記録する。
			var result:NyARDetectMarkerResult = this.result_stack.prePush();
			result.arcode_id = square_index;
			result.confidence = confidence;
	
			var sq:NyARSquare=result.square;
			//directionを考慮して、squareを更新する。
			for(i=0;i<4;i++){
				var idx:int=(i+4 - direction) % 4;
				this._coordline.coord2Line(i_vertex_index[idx],i_vertex_index[(idx+1)%4],i_coordx,i_coordy,i_coor_num,sq.line[i]);
			}
			for (i = 0; i < 4; i++) {
				//直線同士の交点計算
				if(!NyARLinear.crossPos(sq.line[i],sq.line[(i + 3) % 4],sq.sqvertex[i])){
					throw new NyARException();//ここのエラー復帰するならダブルバッファにすればOK
				}
			}
		}
		public function init(i_raster:INyARRgbRaster):void
		{
			this._ref_raster=i_raster;
			this.result_stack.clear();
			
		}
	}
}