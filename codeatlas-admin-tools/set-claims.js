
const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

const serviceAccount = require('./service-account.json');

initializeApp({
  credential: cert(serviceAccount),
});

async function main() {
  const auth = getAuth();
  let nextPageToken;

  do {
    const page = await auth.listUsers(1000, nextPageToken);
    nextPageToken = page.pageToken;

    for (const user of page.users) {
      await auth.setCustomUserClaims(user.uid, {
        ...(user.customClaims || {}),
        role: 'authenticated',
      });

      console.log('Updated:', user.email || user.uid);
    }
  } while (nextPageToken);

  console.log('All existing users updated.');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
