import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';

export function requestMicPhonePermission(
  context: common.UIAbilityContext,
  permissionResult: (allow: boolean) => void
): void {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();

  // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
  let permissions: Array<Permissions> = ['ohos.permission.MICROPHONE'];

  atManager.requestPermissionsFromUser(context, permissions).then((data) => {
    let grantStatus: Array<number> = data.authResults;
    let length: number = grantStatus.length;

    for (let i = 0; i < length; i++) {
      if (grantStatus[i] === 0) {
        // 用户授权，可以继续访问目标操作
        permissionResult(true);
        console.debug("tags：麦克风授权成功：用户授权");
      } else {
        // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
        permissionResult(false);
        console.debug("tags：麦克风授权失败：用户拒绝");
        return;
      }
    }

    // 授权成功
  }).catch((err: BusinessError) => {
    permissionResult(false);
    console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
  });
}