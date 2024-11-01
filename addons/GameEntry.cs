
using Godot;
namespace Panty;
public partial class GameEntry : Node,IPermissionProvider
{
    IModuleHub IPermissionProvider.Hub => GameInitHUb.GetIns();
    public override void _Ready()
    {
        GD.Print("GameEntry框架初始完毕");
        this.GetModel<ITaskScheduler>().AddDelayTask(1f, () => GD.Print("延迟一秒执行"), true);
        base._Ready();
    }

    public override void _ExitTree()
    { 
        this.Dispose();
        base._ExitTree();
    }
}
