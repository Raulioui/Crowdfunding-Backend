/** @type {import('next').NextConfig} */
const nextConfig = {
    images: {
        remotePatterns: [
          {
            protocol: 'https',
            hostname: 'dweb.link',
            port: '',
          },
          {
            protocol: 'https',
            hostname: '1.bp.blogspot.com',
            port: '',
          },
          {
            protocol: 'https',
            hostname: "ipfs.io",
            port: '',
          },
        ],
      },
};

export default nextConfig;
