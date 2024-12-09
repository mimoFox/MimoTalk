// 格式化时间显示
export function formatTime(timeValue: number) {
  // 格式化时间-> 基础版业务
  // 不是今年:2023-11-11
  // 今年:11-11
  // 这个月:12天前
  // 这1周:星期五
  // 当天:20:52
  // 这1小时内:50分钟前
  // 这1分钟内:刚刚
  let now = new Date();
  let targetDate = new Date(timeValue);

  // 获取当前日期的年月日
  let currentYear = now.getFullYear();
  let currentMonth = now.getMonth() + 1; // 月份从0开始，需要加1
  let currentDay = now.getDate();

  // 获取目标日期的年月日
  let targetYear = targetDate.getFullYear();
  let targetMonth = targetDate.getMonth() + 1;
  let targetDay = targetDate.getDate();

  // 判断是否为同一天
  if (currentYear === targetYear && currentMonth === targetMonth && currentDay === targetDay) {
    // 是同一天，返回具体时间并补零
    return padZero(targetDate.getHours()) + ":" + padZero(targetDate.getMinutes());
  } else if (currentYear != targetYear) {
    // 不是同一天，返回具体日期并补零
    return targetYear + "-" + padZero(targetMonth) + "-" + padZero(targetDay);
  } else {
    return padZero(targetMonth) + "-" + padZero(targetDay);
  }

}

// 补零函数
function padZero(num: number) {
  return num < 10 ? '0' + num : num;
}