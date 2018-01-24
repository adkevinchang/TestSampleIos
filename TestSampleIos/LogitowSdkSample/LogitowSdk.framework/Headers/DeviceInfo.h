//
//  DeviceInfo
//  LogitowSdk
//
//  Created by kevin 2018.01.23
//  Copyright (c) 2018年 帕拉卡. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BabyBluetooth.h"
#import <CoreBluetooth/CoreBluetooth.h>

/**
 * @brief LOGITOW_DeviceInfo 逻辑塔设备信息
 */
@interface DeviceInfo : NSObject

/**
 * @brief 设备唯一地址
 */
@property (nonatomic, copy) NSString *addr;

/**
 * @brief 外部设备的功能描述对象
 */
@property (nonatomic,strong)CBCharacteristic *characteristic;
/**
 * @brief 外部设备的模块描述对象
 */
@property (nonatomic,strong)CBCharacteristic *modelcharacteristic;
/**
 * @brief 外部设备对象
 */
@property (nonatomic,strong)CBPeripheral *currPeripheral;

/**
 * @brief 设备连接状态 0 未连接，1 连接
 */
@property int connected;

/**
 * @brief 设备电量值
 */
@property int power;


@end
