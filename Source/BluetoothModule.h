//
//  GSEventModule.h
//  WeexEros
//
//  Created by caas on 2019/3/30.
//  Copyright © 2019 benmu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXModuleProtocol.h"
#import "ConnecterManager.h"

@interface BluetoothModule : NSObject<WXModuleProtocol>

/**
 * 是否支持蓝牙设备
 */
- (void)isSupport:(WXModuleCallback)callback;

/**
 * 蓝牙是否启用
 */
- (void)isEnabled:(WXModuleCallback)callback;

/**
 *  搜索蓝牙打印机
 *
 * @param callback 回调
 */
- (void)searchDevices:(WXModuleCallback)callback;

/**
 * 停止扫描
 */
- (void)stopScane;

/**
 * 断开连接
 */
- (void)disconnectPrinter;

/**
 *  连接蓝牙打印机
 *
 * @param deviceAddress 设备标识
 * @param successCallback 回到
 */
- (void)bondDevice:(NSString *)deviceAddress callback:(WXModuleCallback)callback;

/**
 *  打印标签 json
 {
 width: 30,
 height: 50,
 gap: 30,
 direction: DIRECTION.FORWARD,
 density:DENSITY.DNESITY3,
 mirror: MIRROR.NORMAL,
 speed:PRINT_SPEED.SPEED1DIV5,
 reference: [0, 0],
 tear: 0,
 sound: 0,
 address: "DC:0D:30:04:33:69",
 reverse:[{x:0,y:0,width:0,height:0}],
 text: [{
 text: 'I am a testing txt',
 x: 20,
 y: 0,
 fonttype: FONTTYPE.SIMPLIFIED_CHINESE,
 rotation: ROTATION.ROTATION_0,
 xscal:FONTMUL.MUL_1,
 yscal: FONTMUL.MUL_1
 },{
 text: '你在说什么呢?',
 x: 20,
 y: 100,
 fonttype: FONTTYPE.SIMPLIFIED_CHINESE,
 rotation: ROTATION.ROTATION_0,
 xscal:FONTMUL.MUL_1,
 yscal: FONTMUL.MUL_1,
 bold:true
 }],
 qrcode: [{x: 300, y: 30, level: EEC.LEVEL_L, width: 3, rotation: ROTATION.ROTATION_0, code: 'show me the money'}],
 barcode: [{x: 160, y:150, type: BARCODETYPE.CODE128, height: 40, readabel: 1, rotation: ROTATION.ROTATION_0, code: '1234567890'}],
 image: [{x: 0, y: 0, mode: BITMAP_MODE.OVERWRITE, width: 200, image: base64Image}]
 }
 */
- (void)enableBluetooth:(NSMutableDictionary *)jsonData callback:(WXModuleCallback)callback;

@end

