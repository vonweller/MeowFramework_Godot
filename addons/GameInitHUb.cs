
namespace Panty;
public class GameInitHUb:ModuleHub<GameInitHUb>
{
    protected override void BuildModule()
    {
        AddModule<ITaskScheduler>(new TaskScheduler(new WeDotTimeInfo(0.02f,1f,1f)));//添加任务调度器模块
    }
}
