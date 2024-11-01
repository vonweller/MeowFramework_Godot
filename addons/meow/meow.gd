@tool
extends EditorPlugin
# 插件中的按钮
var script_menu:Button
var my_window: Window
func _enter_tree() -> void:
	# 初始化按钮
	script_menu = Button.new()
	script_menu.text="MeowFrameWorkTool"
	
	script_menu.pressed.connect(_on_menu_item_selected)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR,script_menu)
	pass
	

	

func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR,script_menu)
	pass

# 处理下拉菜单选项的选择
func _on_menu_item_selected():
		ShowMe()
		
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

	

func ShowMe() -> void:
	if my_window == null:
		var window_scene = preload("res://addons//meow//CMDQK.tscn")
		my_window = window_scene.instantiate() if window_scene else null
		if my_window:
			add_child(my_window)
			print("执行窗口弹出")
			my_window.popup()  # 显示窗口
			# 连接 close_requested 信号到关闭函数
			my_window.connect("close_requested", func(): _on_window_close_requested())
			var textinput = my_window.get_child(0)
			var a = my_window.get_child(1)
			var b = my_window.get_child(2)
			if a is Button:
				a.pressed.connect(func():buttons(textinput))
			if b is Button:
				b.pressed.connect(func():generate_script())

		else:
			push_error("Failed to instantiate window from CMDQK.tscn. Check the scene path and root node type.")
	else:
		print("Window is already open.")

	

# 生成ModuleHubC#脚本
func buttons(strs:TextEdit)->void:
	var cl: PackedStringArray=strs.text.split('-')
	if cl.size()<2:
		printerr("请输入md-sss或sys-sss")
		return
	var dir = DirAccess.open("res://MeowScripts")
	if dir:
		print("已存在文件夹")
	else:
		DirAccess.make_dir_absolute("res://MeowScripts")

	if cl[0]=="md":
		var script_content = """
	namespace Panty;
	public interface I{0}: IModule
	{
	
	}
	public class {0} : AbsModule, I{0}
	{
	
	}
	""".format([cl[1]])
		# 写入文件
		var file = FileAccess.open("res://MeowScripts//"+cl[1]+"Module.cs", FileAccess.WRITE)
		if file:
			file.store_string(script_content)
			file.close()
			print("Module脚本创建成功 " + "res://MeowScripts//"+cl[1]+"Module.cs",)
		else:
			printerr("Failed to write the C# Moduleto " +  "res://MeowScripts//"+cl[1]+"Module.cs",)
	
	if cl[0]=="sys":
		var script_contents = """
	namespace Panty;
	public interface I{0}Sys: IModule
	{
	
	}
	public class {0} : AbsModule, I{0}Sys
	{
	
	}
	""".format([cl[1]])
		# 写入文件
		var files = FileAccess.open("res://MeowScripts//"+cl[1]+"Sys.cs", FileAccess.WRITE)
		if files:
			files.store_string(script_contents)
			files.close()
			print("Module脚本创建成功 " + "res://MeowScripts//"+cl[1]+"Sys.cs",)
		else:
			printerr("Failed to write the C# Moduleto " +  "res://MeowScripts//"+cl[1]+"Sys.cs",)
			
# 自定义窗口关闭函数
func _on_window_close_requested():
	if my_window:
		my_window.queue_free()
		my_window = null  # 清空引用


