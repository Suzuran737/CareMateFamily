// EntryAbility：应用入口，启动后加载带底部 Tabs 的主页面
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 保持默认颜色模式
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 窗口创建后，加载主 Tab 页面
    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'onWindowStageCreate');

    windowStage.loadContent('pages/MainTabPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'EntryAbility', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'EntryAbility', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'onBackground');
  }
}
