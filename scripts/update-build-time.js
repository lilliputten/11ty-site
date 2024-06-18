/** @desc Update build date/time tag file with current timestamp
 *  @changed 2024.02.21, 17:18
 */
/* eslint-disable no-console */

const fs = require('fs');
const path = require('path');

const dayjsUtc = require('dayjs/plugin/utc.js');
const dayjsTimezone = require('dayjs-timezone-iana-plugin'); // @see https://day.js.org/docs/en/plugin/timezone
const dayjs = require('dayjs'); // @see https://day.js.org/docs/en/display/format

dayjs.extend(dayjsUtc);
dayjs.extend(dayjsTimezone);

const { getBuildInfo } = require('./gulp-helpers.js');

const buildInfoJsonFilename = 'app-info.json';

const scriptsPath = path.resolve(__dirname);
const rootPath = path.resolve(path.dirname(scriptsPath));
// const prjPath = path.resolve(path.dirname(scriptsPath));
const prjPath = process.cwd();
const srcPath = path.resolve(prjPath, 'src');
const staticPath = path.resolve(prjPath, 'static');

// TODO: Add local config
const configFileName = path.resolve(rootPath, 'config.js');
const config = require(configFileName);

const defaultTimeZome = config.timeZone || '';

// NOTE: Date formats for 'dayjs', @see https://day.js.org/docs/en/display/format
const tagFormat = 'YYMMDD-HHmm';
const timeTzFormat = 'YYYY.MM.DD HH:mm ZZ';
/** // NOTE: Date formats for `date-fns*` library...
 * const tagFormat = 'yyMMdd-HHmm';
 * const timeTzFormat = 'yyyy.MM.dd, HH:mm zzz';
 */

// Timezone argument should be passed as '--tz={timeZone}`
const timeZone = getTzFromArgs() || defaultTimeZome; // 'Europe/Moscow', 'GMT, etc

const now = new Date();
const buildTag = formatDate(now, timeZone, tagFormat);
const buildTzTime = formatDate(now, timeZone, timeTzFormat);

/* console.log('DEBUG', {
 *   config,
 *   configFileName,
 *   argv: process.argv,
 *   args: process.args,
 *   now,
 *   buildTag,
 *   buildTime,
 *   buildTzTime,
 *   timeZone,
 * });
 */

const timestampFileName = path.resolve(rootPath, 'build-timestamp.txt');
const timetagFileName = path.resolve(rootPath, 'build-timetag.txt');
// const versionFileName = path.resolve(rootPath, 'build-version.txt');

console.log('Updated build tag/time:', buildTag, '/', buildTzTime);

// Update timetags...
fs.writeFileSync(timetagFileName, buildTag, 'utf8');
fs.writeFileSync(timestampFileName, buildTzTime, 'utf8');

// Write build info data to use in the source code (if the folder already exists)...
if (fs.existsSync(srcPath)) {
  const buildInfoJsonFileName = path.resolve(srcPath, buildInfoJsonFilename);
  console.log('Creating', buildInfoJsonFilename, 'file...');
  fs.writeFileSync(buildInfoJsonFileName, JSON.stringify(getBuildInfo(), undefined, 2) + '\n', 'utf8');
}

function formatDate(date, timeZone, fmt) {
  let dayjsDate = dayjs(date);
  if (timeZone) {
    dayjsDate = dayjsDate.tz(timeZone);
  }
  const fmtDate = dayjsDate.format(fmt);
  return fmtDate;
  /* // OLD_CODE: Using 'date-fns-tz'
  if (timeZone) {
    return formatInTimeZone(date, timeZone, fmt);
  } else {
    return format(date, fmt);
  }
  */
}

function getTzFromArgs() {
  const args = process.argv.slice(2);
  const lookup = '--tz=';
  for (const s of args) {
    if (s.startsWith(lookup)) {
      return s.substring(lookup.length);
    }
  }
}
