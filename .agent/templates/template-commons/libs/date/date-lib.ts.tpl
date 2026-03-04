export class DateLib {
  getCurrentDate() {
    const currentDate = new Date();
    const year = currentDate.getFullYear();
    const month = String(currentDate.getMonth() + 1).padStart(2, '0');
    const day = String(currentDate.getDate()).padStart(2, '0');

    return `${year}-${month}-${day}`;
  }

  getBogotaDate(): string {
    const date = new Date();

    const options: Intl.DateTimeFormatOptions = {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      timeZone: 'America/Bogota',
    };

    const formattedDate = date.toLocaleDateString('es-CO', options);

    const [day, month, year] = formattedDate.split('/');

    return `${year}/${month}/${day}`;
  }

  getBogotaTimeIn24Hours(): string {
    const date = new Date();
    const utc = date.getTime() + date.getTimezoneOffset() * 60000;
    const bogotaTime = new Date(utc + 3600000 * -5);
    const hours = bogotaTime.getHours();
    const minutes = bogotaTime.getMinutes();
    const seconds = bogotaTime.getSeconds();

    const formattedHours = hours < 10 ? `0${hours}` : hours;
    const formattedMinutes = minutes < 10 ? `0${minutes}` : minutes;
    const formattedSeconds = seconds < 10 ? `0${seconds}` : seconds;

    return `${formattedHours}:${formattedMinutes}:${formattedSeconds}`;
  }

  getBogotaDateTimeWithMilliseconds(): string {
    const date = new Date();
    const utc = date.getTime() + date.getTimezoneOffset() * 60000;
    const bogotaDate = new Date(utc + 3600000 * -5);

    const year = bogotaDate.getFullYear();
    const month = String(bogotaDate.getMonth() + 1).padStart(2, '0');
    const day = String(bogotaDate.getDate()).padStart(2, '0');
    const hours = String(bogotaDate.getHours()).padStart(2, '0');
    const minutes = String(bogotaDate.getMinutes()).padStart(2, '0');
    const seconds = String(bogotaDate.getSeconds()).padStart(2, '0');
    const milliseconds = String(bogotaDate.getMilliseconds()).padStart(3, '0');

    return `${year}-${month}-${day}T${hours}:${minutes}:${seconds}.${milliseconds}`;
  }
}
