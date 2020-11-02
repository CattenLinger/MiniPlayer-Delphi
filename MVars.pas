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
  M: HWND; // ʵ�ֻ��Ⲣ�Ҵ��ݴ��ļ���Ϣ�������δ򿪳���
  FilePath: String; // �ļ�·��

  hs: DWORD; // �� DWORD
  OFileFlag: Boolean;
  MiniSize: Boolean; // �Ƿ�����ģʽ
  StayOnTop: Boolean; // �����Ƿ�����ǰ
  NotCloseButHide: Boolean; // �ر�ʱ��ֱ�ӹرջ�����С������ͼ��

  FormMinSize: Integer = 129; // ����Ĭ�ϳߴ緶Χ
  FormMaxSize: Integer = 486;

  ReplayFlag: Boolean; // �ز�������־
  Playing: Boolean; // �����б�־
  MyPath: string; // ����λ��


  OptionFile: TIniFile; // �����ļ�
  l: Integer;
  AllowTaskBar: Boolean;
  // ��Դ�ļ���ȡ

  // �����б���ر���

  StaChange: Boolean; // �������
  ListName: string; // PlayList�ļ�������
  PlayingIndex: Integer; // ���ڲ��ŵ��ļ������
  ListCreated: Boolean;
  PlayFilePaths: TStringList;

  PlayMode: Integer;
  ListPage: Integer;
  FFTCanvas: TBitmap;
  // FFT��ʾ��ر���
  GetFFTData: TFFTData; // ԭ����
  VisualType: Integer; // Ƶ������
  FFTPeacks: array [0 .. 127] of Integer;
  FFTFallOff: array [0 .. 127] of Integer;
  // �������
  PlayedTime: Integer; // �Ѿ����ŵ�ʱ��
  AllTime: Integer; // �ܹ���ʱ��
  ElseTime: Integer; // ʣ�µ�ʱ��
  VolumeNow: Single; // ����
  PosPlaying: Boolean = False; // �����϶����Ƿ񱻰���
  PosVoloume: Boolean = False; // �����϶����Ƿ񱻰���

  UseTags:Boolean;//Tags Switch

  LtempL, LtempL2: Double;
  LtempR, LtempR2: Double;

  BodyBusying: Boolean;
  ListBusying: Boolean;
  // ���
  ERROR_PLUS: HPLUGIN;
  Info: ^Bass_PluginInfo;

  OpenFilter: string;
  OpenDirFilter: string;

  // ���ñ���
  FormX, FormY: Integer;

implementation

end.
