//
//  LogitowSdk.m
//  LogitowSdk
//
//  Created by paracrakevin on 2018/1/23.
//  Copyright © 2018年 paracra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogitowSdk.h"
#import "BabyBluetooth.h"
#import "DeviceInfo.h"

@implementation LogitowSdk{
    BabyBluetooth *bblue;
}

//单例模式
+ (instancetype)getInstand {
    static LogitowSdk *_instand = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _instand = [[LogitowSdk alloc]init];
    });
    return _instand;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        //初始化对象
        _currFindDevices = [[NSMutableArray alloc]init];
        bblue = [BabyBluetooth shareBabyBluetooth];
        _connected = false;
        _defaultCallback = [[LogitowCallBack alloc]init];
        [self blueDelegate];
    }
    return self;
}

- (void) connectLogitowDevice:(NSString *)daddr
{
    if(self.defaultCallback.deviceOnConnect == nil)
    {
        NSLog(@"LogitowSdk-Error----please setDeviceOnConnect Delegate!");
        return;
    }
    if(self.defaultCallback.deviceOnDisconnect == nil)
    {
        NSLog(@"LogitowSdk-Error----please setDeviceOnDisconnect Delegate!");
        return;
    }
    if(self.defaultCallback.updateBleValue == nil)
    {
        NSLog(@"LogitowSdk-Error----please setUpdateBleValue Delegate!");
        return;
    }
    
     DeviceInfo* dinfo = [self getDeviceInfoByAddr:daddr];
    if(dinfo != nil)
    {
        bblue.having(dinfo.currPeripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    }else{
         NSLog(@"LogitowSdk-Error----connectLogitowDevice:no %@ device connected! ",daddr);
    }
}

- (void) startSearchDevice
{
    if(self.defaultCallback.updateFindDevice == nil)
    {
        NSLog(@"LogitowSdk-Error----please setUpdateFindDevice Delegate!");
        return;
    }
    bblue.scanForPeripherals().begin();
}

- (void) stopSearchDevice
{
    [bblue cancelAllPeripheralsConnection];
    [bblue cancelScan];
}

-(void) clearAllBlueTooth
{
    [bblue cancelAllPeripheralsConnection];
    [bblue cancelScan];
    self.connected = false;
    [bblue cancelAllPeripheralsConnection];
    for (__strong DeviceInfo *d in self.currFindDevices) {
        d = nil;
    }
    [_currFindDevices removeAllObjects];
}

- (void) getDevicePower:(NSString *)daddr
{
    if(self.defaultCallback.updateLogitowPower == nil)
    {
        NSLog(@"LogitowSdk-Error----please setUpdateLogitowPower Delegate!");
        return;
    }
    DeviceInfo* dinfo = [self getDeviceInfoByAddr:daddr];
    if(dinfo != nil)
    {
        Byte byte[] = {0xAD,0x02};
        NSData *data = [NSData dataWithBytes:&byte length:sizeof(byte)];
        [dinfo.currPeripheral writeValue:data forCharacteristic:dinfo.modelcharacteristic type:CBCharacteristicWriteWithResponse];
    }else{
        NSLog(@"LogitowSdk-Error----getDevicePower:no %@ device connected! ",daddr);
    }
}

+ (NSString *) sdkVersion
{
    return @"v1.0";
}

//设备断开链接
- (void)setDeviceOnDisconnect:(void (^)(BOOL *connected,NSString *addr))block{
    [self.defaultCallback setDeviceOnDisconnect:block];
}

//设备链接
- (void)setDeviceOnConnect:(void (^)(BOOL *connected,NSString *addr))block{
    [self.defaultCallback setDeviceOnConnect:block];
}

//更新链接的设备
- (void)setUpdateFindDevice:(void (^)(DeviceInfo *dinfo))block{
    [self.defaultCallback setUpdateFindDevice:block];
}

//更新逻辑塔电量
- (void)setUpdateLogitowPower:(void (^)(int level))block{
    [self.defaultCallback setUpdateLogitowPower:block];
}

//更新蓝牙通讯数据
- (void)setUpdateBleValue:(void (^)(NSString *data))block{
    [self.defaultCallback setUpdateBleValue:block];
}

//通过惟一地址获取设备信息
- (DeviceInfo *) getDeviceInfoByAddr:(NSString *)daddr{
    for (DeviceInfo *d in self.currFindDevices) {
        if ([d.addr isEqualToString:daddr]) {
            return d;
        }
    }
    return nil;
}

//根据描述对象的通知状态获取设备信息
- (DeviceInfo *) getDeviceInfoByNotifiy{
    for (DeviceInfo *d in self.currFindDevices) {
        if (d.characteristic && d.characteristic.isNotifying) {
            if(!d.modelcharacteristic.isNotifying)
            return d;
        }
    }
    return nil;
}

//设置蓝牙中心委托
-(void)blueDelegate{
    [bblue setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            NSLog(@"LogitowSdk-info--设备打开成功，开始扫描设备");
        }
    }];
    
    //设置扫描到设备的委托
    [bblue setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        if([peripheral.name  isEqual: BLUE_DEVICE])
        {
            NSLog(@"LogitowSdk-info--搜索到了设备:%@",peripheral.name);
            DeviceInfo* dinfo = [self getDeviceInfoByAddr:peripheral.identifier.UUIDString];
            if(dinfo == nil)
            {
                dinfo = [[DeviceInfo alloc]init];
                dinfo.addr = peripheral.identifier.UUIDString;
                dinfo.currPeripheral = peripheral;
                if (![_currFindDevices containsObject:dinfo]) {
                    [_currFindDevices addObject:dinfo];
                    [_defaultCallback updateFindDevice](dinfo);
                }
            }
        }
    }];
    
    //设置发现设service的Characteristics的委托
    [bblue setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"LogitowSdk-info--找到的service name:%@",service.UUID.UUIDString);
        
        DeviceInfo* dinfo = [self getDeviceInfoByAddr:peripheral.identifier.UUIDString];
        
        if([service.UUID.UUIDString  isEqual: SERVICE_UUID])
        {
            for (CBCharacteristic *c in service.characteristics) {
                if([c.UUID.UUIDString  isEqual: CLIENT_UUID])
                {
                   // NSLog(@"setBlockOnDiscoverCharacteristics:charateristic name is :%@",c.UUID.UUIDString);
                    if(dinfo != nil)
                    {
                        dinfo.characteristic = c;
                    }
                }
            }
        }
        
        if([service.UUID.UUIDString  isEqual: SERVICE_MODEL_UUID])
        {
            for (CBCharacteristic *c in service.characteristics) {
                if([c.UUID.UUIDString  isEqual: CLIENT_MODEL_UUID])
                {
                   // NSLog(@"setBlockOnDiscoverCharacteristics:charateristic name is :%@",c.UUID.UUIDString);
                    if(dinfo != nil)
                    {
                        dinfo.modelcharacteristic = c;
                    }
                }
            }
        }
        
        if(dinfo.characteristic&&dinfo.modelcharacteristic)
        {
            bblue.channel(CHANNEL_ON_VIEW).characteristicDetails(dinfo.currPeripheral,dinfo.characteristic);
        }
    }];
    
    //设置查找设备的过滤器
    [bblue setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        //最常用的场景是查找某一个前缀开头的设备
        if ([peripheralName hasPrefix:BLUE_DEVICE] ) {
            return YES;
        }
        return NO;
        
    }];
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [bblue setBlockOnConnectedAtChannel:CHANNEL_ON_VIEW block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"LogitowSdk-info--设备：%@--连接成功");
        //DeviceInfo* dinfo = [self getDeviceInfoByAddr:peripheral.identifier.UUIDString];
        
       // if(dinfo != nil)
       // {
           // dinfo.connected = 1;
       // }
    }];
    
    //设置设备连接失败的委托
    [bblue setBlockOnFailToConnectAtChannel:CHANNEL_ON_VIEW block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"LogitowSdk-info--设备：%@--连接失败",peripheral.name);
        DeviceInfo* dinfo = [self getDeviceInfoByAddr:peripheral.identifier.UUIDString];
        if(dinfo != nil)
        {
            dinfo.connected = 0;
        }
        self.connected = false;
        [_defaultCallback deviceOnDisconnect](false,peripheral.identifier.UUIDString);
    }];
    
    //设置设备断开连接的委托
    [bblue setBlockOnDisconnectAtChannel:CHANNEL_ON_VIEW block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"LogitowSdk-info--设备：%@--断开连接",peripheral.name);
        DeviceInfo* dinfo = [self getDeviceInfoByAddr:peripheral.identifier.UUIDString];
        if(dinfo != nil)
        {
            dinfo.connected = 0;
            [bblue cancelNotify:dinfo.currPeripheral characteristic:dinfo.characteristic];
            [bblue cancelNotify:dinfo.currPeripheral characteristic:dinfo.modelcharacteristic];
        }
        self.connected = false;
        [_defaultCallback deviceOnDisconnect](false,peripheral.identifier.UUIDString);
    }];
    
    //设置读取characteristics的委托
    [bblue setBlockOnReadValueForCharacteristicAtChannel:CHANNEL_ON_VIEW block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        //NSLog(@"setBlockOnReadValueForCharacteristicAtChannel===characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
        DeviceInfo* dinfo = nil;
        if([characteristics.UUID.UUIDString  isEqual: CLIENT_UUID])
        {
            dinfo = [self getDeviceInfoByAddr:peripheral.identifier.UUIDString];
            [self setNotifiy:dinfo];
        }
        if([characteristics.UUID.UUIDString  isEqual: CLIENT_MODEL_UUID])
        {
            dinfo = [self getDeviceInfoByAddr:peripheral.identifier.UUIDString];
            [self setPowerNotifiy:dinfo];
        }

        if(!self.connected)
        {
            if(dinfo != nil)
            {
                dinfo.connected = 1;
            }
            self.connected = true;
            [_defaultCallback deviceOnConnect](true,peripheral.identifier.UUIDString);
        }
    }];
    
    //设置写数据成功的block
    [bblue setBlockOnDidWriteValueForCharacteristicAtChannel:CHANNEL_ON_VIEW block:^(CBCharacteristic *characteristic, NSError *error) {
        //NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
    }];
    
    //设置通知状态改变的block
    [bblue setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:CHANNEL_ON_VIEW block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"uid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
        if([characteristic.UUID.UUIDString isEqual:CLIENT_UUID])
        {
            if(characteristic.isNotifying)
            {
                DeviceInfo* dinfo = [self getDeviceInfoByNotifiy];
                if(dinfo != nil)
                {
                    bblue.channel(CHANNEL_ON_VIEW).characteristicDetails(dinfo.currPeripheral,dinfo.modelcharacteristic);
                }
            }
        }
    }];
    
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [bblue setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}


//订阅功能描述对象的通知
-(void)setNotifiy:(DeviceInfo*)dinfo{
    NSLog(@"LogitowSdk-info--setNotifiy");
    if(dinfo == nil) return;
    if(dinfo.currPeripheral.state != CBPeripheralStateConnected) {
        NSLog(@"peripheral已经断开连接，请重新连接");
        return;
    }
    if (dinfo.characteristic.properties & CBCharacteristicPropertyNotify ||  dinfo.characteristic.properties & CBCharacteristicPropertyIndicate) {
        if(!dinfo.characteristic.isNotifying) {
            
            [bblue notify:dinfo.currPeripheral
           characteristic:dinfo.characteristic
                    block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                        
                        NSString * result = [[[[NSString stringWithFormat:@"%@",characteristics.value]
                                               stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                              stringByReplacingOccurrencesOfString: @">" withString: @""]
                                             stringByReplacingOccurrencesOfString: @" " withString: @""];
                        //NSLog(@"bluetooth1:%@",result);
                        //const char * anm =[result UTF8String];
                        [_defaultCallback updateBleValue](result);
                    }];
        }
    }
    else{
        NSLog(@"LogitowSdk-info--这个characteristic没有nofity的权限");
        return;
    }
    
}

//订阅电量通知的描述对象
-(void)setPowerNotifiy:(DeviceInfo*)dinfo{
    NSLog(@"LogitowSdk-info--setPowerNotifiy");
    if(dinfo == nil) return;
    if(dinfo.currPeripheral.state != CBPeripheralStateConnected) {
        NSLog(@"peripheral已经断开连接，请重新连接");
        return;
    }
    if (dinfo.modelcharacteristic.properties & CBCharacteristicPropertyNotify ||  dinfo.modelcharacteristic.properties & CBCharacteristicPropertyIndicate) {
        if(!dinfo.modelcharacteristic.isNotifying) {
            
            [bblue notify:dinfo.currPeripheral
           characteristic:dinfo.modelcharacteristic
                    block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                        
                        NSString * result = [[[[NSString stringWithFormat:@"%@",characteristics.value]
                                               stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                              stringByReplacingOccurrencesOfString: @">" withString: @""]
                                             stringByReplacingOccurrencesOfString: @" " withString: @""];
                        
                        NSString *sstr =  [result substringWithRange:NSMakeRange(0, 2)];
                        NSString *gstr =  [result substringFromIndex:2];
                       // NSLog(@"bluetooth2:%@,%@,%@",result,sstr,gstr);
                        
                        UInt64 snum =  strtoul([sstr UTF8String], 0, 16);
                        UInt64 gnum =  strtoul([gstr UTF8String], 0, 16);
                        float gfnum = 0.0f;
                        if(gnum>10)
                        {
                            gfnum = gnum*0.01f;
                        }else if(gnum>100)
                        {
                            gfnum = gnum*0.001f;
                        }
                        float cnum = snum + gfnum;
                        float num = (cnum - 1.5f)*100.f;
                        float fnum = (num/60.f)*100.f;
                        if(fnum<=0.f)
                        {
                            dinfo.power = 0;
                            [_defaultCallback updateLogitowPower](0);
                        }else if(fnum>=100.0f)
                        {
                            dinfo.power = 100;
                            [_defaultCallback updateLogitowPower](100);
                        }else
                        {
                            int lnum;
                            lnum = floor(fnum);
                            dinfo.power = lnum;
                            [_defaultCallback updateLogitowPower](lnum);
                        }
                       // NSLog(@"bluetooth3:%f,%f",fnum,cnum);
                        
                    }];
        }
    }
    else{
        NSLog(@"LogitowSdk-info--这个modelcharacteristic没有nofity的权限");
        return;
    }
    
}

@end
