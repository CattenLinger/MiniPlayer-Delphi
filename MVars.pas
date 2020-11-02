unit MVars;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Bass, ShellAPI, IniFiles;

type
  TimeTypes = (TPPlayed, TPAll, TPElse);
  TFFTData = array [0 .. 512] of Single;
  ArFileTypes = array [0 .. 16] of string;

const
  WM_MYMESSAGE = WM_USER;

  Built_in_FileTypes: ArFileTypes = ('.mp1', '.mp2', '.mp3', '.ogg', '.wav',
    '.aif', '.ape', '.fla', '.flac', '.m4a', '.m4b', '.oga', '.wma', '.aiff',
    '.ac3', '.acc', '.wv');

  Built_in_Filter = 'Monkey`s Audio|*.ape;*.mac' + '|' +
    'Free Lossless Audio Codec|*.flac;*.fla' + '|' +
    'MPEG Audio File|*.mp1;*.mp2;*.mp3' + '|' +
    'Advance Audio Coding MPEG-4|*.m4a;*.m4b;*.mp4' + '|' +
    'Apple Loseless Audio Coding|*.m4a' + '|' +
    'Free Lossless Audio Codec(ogg)|*.oga;*.ogg' + '|' +
    'Microsoft WAV Audio File|*.wav' + '|' + 'Windows Media Audio|*.wma' + '|' +
    'Audio Interchange File Format|*.aiff' + '|' + 'AC3 Audio File|*.ac3' + '|'
    + 'Advance Audio Coding|*.acc' + '|' + 'The True Audio|*.tta' + '|' +
    'WavePack|*.wv'; // }

  Built_in_Filter_All = 'All|*.mp3;*.mp2;*.mp1;*.ogg;*.wav*;*.aif;' +
    '*.ape;*.mac;*.flac;*.fla;*.m4a;*.m4b;*.mp4;*.oga;' +
    '*.wma;*.aiff;*.ac3;*.acc;*.wv';

var
  K, J: Word;
  M: HWND; // 实现互斥并且传递打开文件消息而不二次打开程序。
  FilePath: String; // 文件路径

  hs: DWORD; // 流 DWORD
  OFileFlag: Boolean;
  MiniSize: Boolean; // 是否迷你模式
  StayOnTop: Boolean; // 窗体是否在最前
  NotCloseButHide: Boolean; // 关闭时是直接关闭还是缩小到托盘图标

  FormMinSize: Integer = 129; // 窗体默认尺寸范围
  FormMaxSize: Integer = 486;

  ReplayFlag: Boolean; // 重播歌曲标志
  Playing: Boolean; // 播放中标志
  MyPath: string; // 程序位置


  OptionFile: TIniFile; // 配置文件
  l: Integer;
  AllowTaskBar: Boolean;
  // 资源文件读取

  // 播放列表相关变量

  StaChange: Boolean; // 动作变更
  ListName: string; // PlayList文件的名字
  PlayingIndex: Integer; // 正在播放的文件的序号
  ListCreated: Boolean;
  PlayFilePaths: TStringList;

  PlayMode: Integer;
  ListPage: Integer;
  FFTCanvas: TBitmap;
  // FFT显示相关变量
  GetFFTData: TFFTData; // 原数组
  VisualType: Integer; // 频谱类型
  FFTPeacks: array [0 .. 127] of Integer;
  FFTFallOff: array [0 .. 127] of Integer;
  // 播放相关
  PlayedTime: Integer; // 已经播放的时间
  AllTime: Integer; // 总共的时间
  ElseTime: Integer; // 剩下的时间
  VolumeNow: Single; // 音量
  PosPlaying: Boolean = False; // 播放拖动条是否被按下
  PosVoloume: Boolean = False; // 音量拖动条是否被按下

  UseTags:Boolean;//Tags Switch

  LtempL, LtempL2: Double;
  LtempR, LtempR2: Double;

  BodyBusying: Boolean;
  ListBusying: Boolean;
  // 插件
  ERROR_PLUS: HPLUGIN;
  Info: ^Bass_PluginInfo;

  OpenFilter: string;
  OpenDirFilter: string;

  // 配置变量
  FormX, FormY: Integer;

implementation

end.
