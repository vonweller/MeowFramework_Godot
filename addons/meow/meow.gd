@tool
extends EditorPlugin
# 插件中的按钮
var script_menu:MenuButton

func _enter_tree() -> void:
	# 初始化按钮
	script_menu = MenuButton.new()
	script_menu.text="MeowFrameWorkTool"
	
	var popup = script_menu.get_popup()
	popup.add_item("(Init_MeowFameWork)初始化游戏框架",1)
	popup.id_pressed.connect(_on_menu_item_selected)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR,script_menu)
	pass
	

	

func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR,script_menu)
	pass

# 处理下拉菜单选项的选择
func _on_menu_item_selected(id):
	if id == 1:
		generate_script()

		
# 生成ModuleHubC#脚本
func generate_script():
	var dir = DirAccess.open("res://MeowScripts")
	if dir:
		print("已存在文件夹")
	else:
		DirAccess.make_dir_absolute("res://MeowScripts")

	
	
	var script_content = """
namespace Panty;
public class GameInitHUb:ModuleHub<GameInitHUb>
{
    protected override void BuildModule()
    {
        AddModule<ITaskScheduler>(new TaskScheduler(new WeDotTimeInfo(0.02f,1f,1f)));//添加任务调度器模块
    }
}
"""
	
	# 写入文件
	var file = FileAccess.open("res://MeowScripts//GameInitHUb.cs", FileAccess.WRITE)
	if file:
		file.store_string(script_content)
		file.close()
		print("GameInitHUb框架脚本创建成功 " +  "res://MeowScripts//GameInitHUb.cs")
	else:
		printerr("Failed to write the C# GameInitHUbscript to " +  "res://GameInitHUb.cs")

	var script_contentGameEntry = """
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
"""
	# 写入文件
	var files = FileAccess.open("res://MeowScripts//GameEntry.cs", FileAccess.WRITE)
	if files:
		files.store_string(script_contentGameEntry)
		files.close()
		print("GameEntry框架脚本创建成功 " +  "res://MeowScripts//GameEntry.cs")
	else:
		printerr("Failed to write the C# GameEntryscript to " + "res://MeowScripts//GameEntry.cs")