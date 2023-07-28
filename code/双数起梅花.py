import os


print('    双 数 起 卦    ')
print('')
print('  至诚无息，可以前知  ')
print('')
print('')

number1 = int(input("  请输入第一个数字："))
number2 = int(input("  请输入第二个数字："))

up_gua = (number1 % 8) if (number1 % 8) else 8
down_gua = (number2 % 8) if (number2 % 8) else 8

dong_yao = (number1 + number2) % 6

if (dong_yao == 0):
    dong_yao = 6

gua_dict = {
    1: "乾",
    2: "兑",
    3: "离",
    4: "震",
    5: "巽",
    6: "坎",
    7: "艮",
    8: "坤",
    0: "坤"
}


print("上卦：", gua_dict[up_gua])
print("下卦：", gua_dict[down_gua])
print("动爻：", dong_yao)

os.system('pause')