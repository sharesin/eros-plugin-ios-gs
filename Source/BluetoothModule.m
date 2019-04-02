//
//  GSEventModule.m
//  WeexEros
//
//  Created by caas on 2019/3/30.
//  Copyright © 2019 benmu. All rights reserved.
//

#import "BluetoothModule.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import "EscCommand.h"
#import "TscCommand.h"

#import <WeexPluginLoader/WeexPluginLoader.h>
// 第一个参数为暴露给 js 端 Module 的名字，
// 第二个参数为你 Module 的类名
WX_PlUGIN_EXPORT_MODULE(BluetoothModule, GSEventModule)

@interface BluetoothModule ()

@property(nonatomic,strong)NSMutableDictionary *dicts;
@property(nonatomic,strong)NSMutableArray *blueDevices;

@property(nonatomic,strong)CBCentralManager *bluetoothManager;

@property(nonatomic, strong) NSString *support;
@property(nonatomic, strong) NSString *enable;

@end

@implementation BluetoothModule

// 将方法暴露出去
WX_EXPORT_METHOD(@selector(isSupport:))
WX_EXPORT_METHOD(@selector(isEnabled:))
WX_EXPORT_METHOD(@selector(searchDevices:))
WX_EXPORT_METHOD(@selector(disconnectPrinter))
WX_EXPORT_METHOD(@selector(bondDevice:callback:))
WX_EXPORT_METHOD(@selector(enableBluetooth:callback:))

@synthesize weexInstance;

-(NSMutableDictionary *)dicts {
    if (!_dicts) {
        _dicts = [[NSMutableDictionary alloc]init];
    }
    return _dicts;
}
-(NSMutableArray *)blueDevices {
    if (!_blueDevices) {
        _blueDevices = [[NSMutableArray alloc]init];
    }
    return _blueDevices;
}

-(CBCentralManager *)bluetoothManager {
    if (_bluetoothManager == nil) {
        _bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _bluetoothManager;
}

/**
 * 是否支持蓝牙设备
 */
- (void)isSupport:(WXModuleCallback)callback {
    [self.bluetoothManager.delegate centralManagerDidUpdateState:self.bluetoothManager];
    callback(_support);
}

/**
 * 蓝牙是否启用
 */
- (void)isEnabled:(WXModuleCallback)callback {
    [self.bluetoothManager.delegate centralManagerDidUpdateState:self.bluetoothManager];
    callback(_enable);
}

/**
 *  搜索蓝牙打印机
 *
 * @param callback 回调
 */
- (void)searchDevices:(WXModuleCallback)callback {
    
    if (Manager.bleConnecter == nil) {
        [Manager didUpdateState:^(NSInteger state) {
            switch (state) {
                    case CBCentralManagerStateUnsupported:
                    NSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
                    break;
                    case CBCentralManagerStateUnauthorized:
                    NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
                    break;
                    case CBCentralManagerStatePoweredOff:
                    NSLog(@"Bluetooth is currently powered off.");
                    break;
                    case CBCentralManagerStatePoweredOn:
                    [self startScane:callback];
                    NSLog(@"Bluetooth power on");
                    break;
                    case CBCentralManagerStateUnknown:
                default:
                    break;
            }
        }];
    } else {
        [self startScane:callback];
    }
}

/**
 * 停止扫描
 */
- (void)stopScane {
    [Manager stopScan];
}

/**
 * 断开连接
 */
- (void)disconnectPrinter {
    [Manager close];
}

/**
 *  连接蓝牙打印机
 *
 * @param deviceAddress 设备标识
 * @param successCallback 回到
 */
- (void)bondDevice:(NSString *)deviceAddress callback:(WXModuleCallback)callback {
    CBPeripheral *peripheral ;//= //[[self.dicts objectForKey:uuid] objectForKey:@"obj"];
    for (int i = 0; i < [self.blueDevices count] ; i ++) {
        NSMutableDictionary *info = [self.blueDevices objectAtIndex:i];
        if ([deviceAddress isEqualToString:[info objectForKey:@"deviceAddress"]]) {
            peripheral = [info objectForKey:@"obj"];
            break;
        }
    }
    [Manager connectPeripheral:peripheral options:nil timeout:2 connectBlack:^(ConnectState state) {
        if (state == CONNECT_STATE_CONNECTED) {
            if (callback) {
                callback(@"1");
            }
        }else {
            if (callback) {
                callback(@"0");
            }
        }
    }];
}

/**
 *  打印标签 json
 */
- (void)enableBluetooth:(NSMutableDictionary *)jsonData callback:(WXModuleCallback)callback {
    [Manager write:[self tscCommand:jsonData]];
    callback(@"true");
}

/**
 {
 "width": 750,
 "height": 50,
 "gap": 2,
 "direction": 0,
 "density": 3,
 "mirror": 0,
 "speed": 1,
 "reference": [
 0,
 0
 ],
 "tear": 0,
 "sound": 0,
 "address": "DC:0D:30:04:33:69",
 "reverse": [{
 "x": 0,
 "y": 0,
 "width": 0,
 "height": 0
 }],
 "text": [{
 "text": "I am a testing txt",
 "x": 20,
 "y": 10,
 "fonttype": "TSS24.BF2",
 "rotation": 0,
 "xscal": 1,
 "yscal": 1
 },
 {
 "text": "你在说什么呢?",
 "x": 20,
 "y": 50,
 "fonttype": "TSS24.BF2",
 "rotation": 0,
 "xscal": 1,
 "yscal": 1,
 "bold": true
 }
 ],
 "qrcode": [{
 "x": 20,
 "y": 100,
 "level": "L",
 "width": 3,
 "rotation": 0,
 "code": "show me the money"
 }],
 "barcode": [{
 "x": 20,
 "y": 300,
 "type": "128",
 "height": 40,
 "readabel": 1,
 "rotation": 0,
 "code": "1234567890"
 }],
 "image": [{
 "x": 300,
 "y": 10,
 "mode": 0,
 "width": 200,
 "image": "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAMAAABg3Am1AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAA8FBMVEUAAABCQkJDQ0NFRUU/Pz9BQUFAQEBERERDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0MAAAA0ZZMIAAAATnRSTlMAAAAAAAAAABWFz8JdBQFHt9OYIxSi/PBsBFHjvCSk/vJt5b7mo26h75ziIZkD1csRXvpziwvx+QadveRSSA3XF6r31DMPOSLWzMTZFgd4wftfAAAAAWJLR0QAiAUdSAAAAAlwSFlzAAALEgAACxIB0t1+/AAAAaBJREFUSMe11dlSwjAUgOE2WmUTQRBtBQVBREREQEVUFkHcz/s/jklbQ7YOhwtz2fzftJ1OTi0rWDaJxRPJ1A6xxEXSu5nsXo7Ylrpskt8vABwcuqIgG94RABRLmtgk+eMTugXliiAI8U7ZRaiqwvnrJUH7WnBRFfR5zsKeinoohN4XRHyeZc8F2RJ6SSh9KJReeCpH7QOh9st76L3/5lrPRf5c6wEaF039IlQvmYgXAL1aVxQk8D20YxQk1wDXHQpuGui+22Pv4FbK2L5/639Rt44TYY8WvEcKoUcJqUcIpV8ptN4Xd5H9vd5TMXiIBMOOoXe8x0igzJKgf6pB9JJmCaIXJkPYb6/oFYHoJYHqxXllo/qlcDxcz8VzE9lTkWInLoPuAZIjCrJrgPGEgtYaYDqgIFc07LwMTbNkNmfvQEpVbafbfzXMkvbCn622Lth50adP2BuEf740MVvwP4oi+LyShNArQphXgpB69v/jQppXXCi9IJR5FQqt50KbV74w9Ey8td4/etq8Sn1+TeeGngn3u5PW7myPJj/G/v/WL4DMswebZ4AxAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDE1LTA2LTI1VDA4OjQ0OjQ2KzA4OjAww1b9dwAAACV0RVh0ZGF0ZTptb2RpZnkAMjAxNS0wNi0yNVQwODo0NDo0NiswODowMLILRcsAAAAASUVORK5CYII="
 }]
 }
 */
-(NSData *)tscCommand:(NSMutableDictionary *)info{
    
    TscCommand *command = [[TscCommand alloc]init];
    //设置标签尺寸的宽和高
    if ([info objectForKey:@"width"] && [info objectForKey:@"height"]) {
        [command addSize:[[info objectForKey:@"width"] intValue] :[[info objectForKey:@"height"] intValue]];
    }
    //设置标签间隙尺寸 单位mm
    if ([info objectForKey:@"gap"]) {
        [command addGapWithM:[[info objectForKey:@"gap"] intValue] withN:0];
    }
    //打印方向
    if ([info objectForKey:@"direction"]) {
        [command addDirection:[[info objectForKey:@"direction"] intValue]];
    }
    //打印浓度
    if ([info objectForKey:@"density"]) {
        [command addDensity:[[info objectForKey:@"density"] intValue]];
    }
    //mirror
    //设置打印速度
    if ([info objectForKey:@"speed"]) {
        [command addSpeed:[[info objectForKey:@"speed"] intValue]];
    }
    //设置标签原点坐标
    if ([info objectForKey:@"reference"]) {
        NSArray *arr = [info objectForKey:@"reference"];
        if ([arr count] == 0) {
            [command addReference:[[arr objectAtIndex:0] intValue] :[[arr objectAtIndex:1] intValue]];
        }else {
            [command addReference:0 :0];
        }
    }
    //设置打印机撕离模式
    if ([info objectForKey:@"tear"]) {
        if([[info objectForKey:@"tear"] intValue] == 0){
            [command addTear:@"OFF"];
        }else if([[info objectForKey:@"tear"] intValue] == 1) {
            [command addTear:@"ON"];
        }else {
            [command addTear:@"OFF"];
        }
    }
    //设置蜂鸣器
    if ([info objectForKey:@"sound"]) {
        [command addSound:[[info objectForKey:@"sound"] intValue] :0];
    }
    //address
    //将指定的区域反向打印（黑色变成白色，白色变成黑色）
    if ([info objectForKey:@"reverse"]) {
        NSDictionary *dic =[[info objectForKey:@"reverse"] objectAtIndex:0];
        [command addReverse:[[dic objectForKey:@"x"] intValue] :[[dic objectForKey:@"y"] intValue] :[[dic objectForKey:@"width"] intValue] :[[dic objectForKey:@"height"] intValue]];
    }else {
        [command addReverse:0 :0 :0 :0];
    }
    //在标签上绘制文字
    if ([info objectForKey:@"text"]) {
        NSArray *arr =[info objectForKey:@"text"];
        for (int i = 0; i < [arr count]; i ++) {
            NSDictionary *dic = [arr objectAtIndex:i];
            [command addTextwithX:[[dic objectForKey:@"x"] intValue] withY:[[dic objectForKey:@"y"] intValue] withFont:[dic objectForKey:@"fonttype"] withRotation:[[dic objectForKey:@"rotation"] intValue] withXscal:[[dic objectForKey:@"xscal"] intValue] withYscal:[[dic objectForKey:@"yscal"] intValue] withText:[dic objectForKey:@"text"]];
        }
        
    }
    //在标签上绘制QRCode二维码
    if ([info objectForKey:@"qrcode"]) {
        NSArray *arr =[info objectForKey:@"qrcode"];
        for (int i = 0; i < [arr count]; i ++) {
            NSDictionary *dic = [arr objectAtIndex:i];
            [command addQRCode:[[dic objectForKey:@"x"] intValue]  :[[dic objectForKey:@"y"] intValue] :[dic objectForKey:@"level"] :[[dic objectForKey:@"width"] intValue] :@"A" :[[dic objectForKey:@"rotation"] intValue] :[dic objectForKey:@"code"]];
        }
    }
    //在标签上绘制一维条码
    if ([info objectForKey:@"barcode"]) {
        NSArray *arr =[info objectForKey:@"barcode"];
        for (int i = 0; i < [arr count]; i ++) {
            NSDictionary *dic = [arr objectAtIndex:i];
            [command add1DBarcode:[[dic objectForKey:@"x"] intValue]  :[[dic objectForKey:@"y"] intValue] :[NSString stringWithFormat:@"CODE%@", [dic objectForKey:@"type"]] :[[dic objectForKey:@"height"] intValue] :[[dic objectForKey:@"readabel"] intValue] :[[dic objectForKey:@"rotation"] intValue] :2 :2 :[dic objectForKey:@"code"]];
        }
    }
    //图片
    if ([info objectForKey:@"image"]) {
        NSArray *arr =[info objectForKey:@"image"];
        for (int i = 0; i < [arr count]; i ++) {
            NSDictionary *dic = [arr objectAtIndex:i];
            UIImage *image = [self decodeBase64ToImage:[dic objectForKey:@"image"]];
            [command addBitmapwithX:[[dic objectForKey:@"x"] intValue]  withY:[[dic objectForKey:@"y"] intValue]  withMode:[[dic objectForKey:@"mode"] intValue]  withWidth:[[dic objectForKey:@"width"] intValue] withImage:image];
        }
    }
    [command addPrint:1 :1];
    return [command getCommand];
    
}


/**
 * 搜索蓝牙打印机
 */
- (void) startScane:(WXModuleCallback)successCallback {
    [Manager scanForPeripheralsWithServices:nil options:nil discover:^(CBPeripheral * _Nullable peripheral, NSDictionary<NSString *,id> * _Nullable advertisementData, NSNumber * _Nullable RSSI) {
        if (peripheral.name != nil) {
            NSLog(@"name -> %@",peripheral.name);
//            NSUInteger oldCounts = [self.dicts count];
//            NSMutableDictionary *info = [[NSMutableDictionary alloc]init];
//            [info setObject:peripheral forKey:@"obj"];
//            [info setObject:peripheral.name forKey:@"name"];
//            [self.dicts setObject:info forKey:peripheral.identifier.UUIDString];
            
            NSUInteger oldCounts = [self.blueDevices count];
            NSMutableDictionary *info = [[NSMutableDictionary alloc]init];
            [info setObject:peripheral.identifier.UUIDString forKey:@"deviceAddress"];
            [info setObject:peripheral forKey:@"obj"];
            [info setObject:peripheral.name forKey:@"deviceName"];
            [self.blueDevices addObject:info];
        
            if (oldCounts < [self.blueDevices count]) {
                if (successCallback) {
                    successCallback(self.blueDevices);
                }
            }
            
        }
    }];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    self.enable = @"true";
    self.support  = @"true";
    switch (central.state) {
            case CBCentralManagerStatePoweredOff:{
            }
            break;
            case CBCentralManagerStatePoweredOn:{
                self.enable = @"true";
            }
            break;
            case CBCentralManagerStateResetting:
            break;
            case CBCentralManagerStateUnauthorized:
            break;
            case CBCentralManagerStateUnknown:{
                self.enable = @"true";
            }
            break;
            case CBCentralManagerStateUnsupported:{
                self.support  = @"false";
            }
            break;
        default:
            break;
    }
    
}
                              
- (UIImage*)decodeBase64ToImage:(NSString*)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}
                              

@end
