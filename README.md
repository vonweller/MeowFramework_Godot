# MeowFrameWork——Godot

## 介绍
![alt text](<MeowToolKit Logo1-1.png>)

# MeowFrameWork——Godot 是MewoFrameWork超高性能框架的Godot版本
框架包含：godot客户端与Fantsay服务端

## [框架任务调度器TaskScheduler使用说明](addons/TaskScheduler用户手册.md)

## [Fantasy使用教程“待更新”](<https://www.bilibili.com/video/BV1o7SjYuEPG/?spm_id_from=333.337.search-card.all.click&vd_source=97fc06ed9ba2fd14ce1fa7aa0910acb7>)


### 示例代码

```csharp
namespace Panty.Test
{
    // 定义模块中心 CalcHub，负责注册模块 ICalcModel 和 IOpSystem
    public class CalcHub : ModuleHub<CalcHub>
    {
        // 构建模块，在这里注册所有需要的模块
        protected override void BuildModule()
        {
            // 注册计算模型模块
            AddModule<ICalcModel>(new CalcModel());
            // 注册操作符系统模块
            AddModule<IOpSystem>(new OpSystem());
        }
    }

    // 定义 CalcGame 类，作为权限提供者，允许访问 CalcHub 中的模块
    public partial  class CalcGame : Node, IPermissionProvider
    {
        // 实现 IPermissionProvider 接口，返回模块中心实例
        IModuleHub IPermissionProvider.Hub => CalcHub.GetIns();
    }

    public partial  class CalcUI : Node, IPermissionProvider
    {
        // 实现 IPermissionProvider 接口，返回模块中心实例
        IModuleHub IPermissionProvider.Hub => CalcHub.GetIns();
    }
}

namespace Panty.Test
{
    // 定义 CalcResultQuery 结构体，实现查询接口，返回计算结果
    public struct CalcResultQuery : IQuery<float>
    {
        // 实现 Do 方法，执行查询操作，返回计算结果
        public float Do(IModuleHub hub)
        {
            // 获取计算模型模块
            var model = hub.Module<ICalcModel>();
            // 获取当前操作符
            string op = hub.Module<IOpSystem>().Op;
            // 获取两个操作数
            int a = model.NumA;
            int b = model.NumB;
            // 根据操作符执行相应的计算
            return op switch
            {
                "+" => a + b,
                "-" => a - b,
                "*" => (float)a * b,
                "/" => (float)a / b,
                _ => int.MaxValue,
            };
        }
    }

    // 定义 NextOpIndexCmd 结构体，实现命令接口，用于切换操作符
    public struct NextOpIndexCmd : ICmd
    {
        // 实现 Do 方法，执行命令操作，切换操作符索引并发送计算命令
        public void Do(IModuleHub hub)
        {
            // 获取操作符系统模块
            hub.Module<IOpSystem>().NextOpIndex();
            // 发送计算命令
            hub.SendCmd<CalcCmd>();
        }
    }

    // 定义 RandomCalcCmd 结构体，实现命令接口，用于生成随机数并发送计算命令
    public struct RandomCalcCmd : ICmd
    {
        // 实现 Do 方法，执行命令操作，生成随机数并发送计算命令
        public void Do(IModuleHub hub)
        {
            // 获取计算模型模块
            var model = hub.Module<ICalcModel>();
            // 生成随机数并赋值给操作数A和B
            model.NumA.Value = Random.Range(1, 100);
            model.NumB.Value = Random.Range(1, 100);
            // 发送计算命令
            hub.SendCmd<CalcCmd>();
        }
    }

    // 定义 CalcCmd 结构体，实现命令接口，用于执行计算并发送事件
    public struct CalcCmd : ICmd
    {
        // 实现 Do 方法，执行计算命令，查询计算结果并发送计算事件
        public void Do(IModuleHub hub)
        {
            // 查询计算结果
            var result = hub.Query<CalcResultQuery, float>();
            // 发送计算结果事件
            hub.SendEvent(new CalcEvent() { result = result });
        }
    }

    // 定义 OpChangeEvent 结构体，用于表示操作符变化事件
    public struct OpChangeEvent
    {
        // 表示当前操作符
        public string op;
    }

    // 定义 CalcEvent 结构体，用于表示计算结果事件
    public struct CalcEvent
    {
        // 表示计算结果
        public float result;
    }

    // 定义 IOpSystem 接口，用于表示操作符系统
    public interface IOpSystem : IModule
    {
        // 获取当前操作符
        string Op { get; }
        // 切换到下一个操作符
        void NextOpIndex();
    }

    // 定义 OpSystem 类，实现操作符系统
    public class OpSystem : AbsModule, IOpSystem
    {
        // 操作符索引
        private int opIndex;
        // 操作符数组
        private string[] ops;
        // 获取当前操作符
        public string Op => ops[opIndex];

        // 实现模块初始化方法，初始化操作符数组和索引
        protected override void OnInit()
        {
            ops = new string[4] { "+", "-", "*", "/" };
            opIndex = 0;
        }

        // 切换到下一个操作符
        public void NextOpIndex()
        {
            opIndex = (opIndex + 1) % ops.Length;
            // 发送操作符变化事件
            this.SendEvent(new OpChangeEvent() { op = ops[opIndex] });
        }
    }

    // 定义 ICalcModel 接口，用于表示计算模型
    public interface ICalcModel : IModule
    {
        // 操作数A
        ValueBinder<int> NumA { get; }
        // 操作数B
        ValueBinder<int> NumB { get; }
    }

    // 定义 CalcModel 类，实现计算模型
    public class CalcModel : AbsModule, ICalcModel
    {
        // 初始化操作数A和B的绑定器
        public ValueBinder<int> NumA { get; } = new ValueBinder<int>(1);
        public ValueBinder<int> NumB { get; } = new ValueBinder<int>(2);

        // 实现模块初始化方法
        protected override void OnInit() { }
    }
}

namespace Panty.Test
{
    // 定义 CalcPanel 类，继承自 CalcUI，负责管理 UI 逻辑
    public class CalcPanel : CalcUI
    {

        // 存储计算模型模块实例
        private ICalcModel mModel;
        // 初始化方法，在 Start 中注册操作数和事件的回调
        public Button getButton; 
        private void _Ready()
        {
            getButton = new Button();
            getButton.ispressed.connect(OnClick);
            // 获取计算模型模块
            mModel = this.Module<ICalcModel>();

            // 注册操作数A和B的值变化回调，并在销毁时移除
            mModel.NumA.RegisterWithInitValue(v => mInputA.text = v.ToString()).RmvOnDestroy(this);
            mModel.NumB.RegisterWithInitValue(v => mInputB.text = v.ToString()).RmvOnDestroy(this);
            // 注册计算结果事件的回调，并在销毁时移除
            this.AddEvent<CalcEvent>(e => mResultText.text = e.result.ToString()).RmvOnDestroy(this);
            // 注册操作符变化事件的回调，并在销毁时移除
            this.AddEvent<OpChangeEvent>(e => mOPText.text = e.op).RmvOnDestroy(this);//this是当前node对象
        }

        // 处理按钮点击事件
        protected void OnClick(string btnName)
        {
            // 根据按钮名称执行不同的命令
            switch (btnName)
            {
                case "Op":
                    // 切换操作符
                    this.SendCmd<NextOpIndexCmd>();
                    break;
                case "Eq":
                    // 执行计算
                    this.SendCmd<CalcCmd>();
                    break;
                case "Add_NumA":
                    // 增加操作数A
                    mModel.NumA.Value++;
                    break;
                case "Add_NumB":
                    // 增加操作数B
                    mModel.NumB.Value++;
                    break;
                case "Sub_NumA":
                    // 减少操作数A
                    mModel.NumA.Value--;
                    break;
                case "Sub_NumB":
                    // 减少操作数B
                    mModel.NumB.Value--;
                    break;
                case "Random":
                    // 生成随机数并执行计算
                    this.SendCmd<RandomCalcCmd>();
                    break;
            }
        }
    }
}
```