import { FlatCompat } from '@eslint/eslintrc';
import nextConfig from 'eslint-config-next/core-web-vitals';
import prettierConfig from 'eslint-config-prettier';
import tailwindPlugin from 'eslint-plugin-tailwindcss';
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const compat = new FlatCompat({ baseDirectory: __dirname });

/** @type {import('eslint').Linter.Config[]} */
const config = [
  ...nextConfig,
  ...tailwindPlugin.configs['flat/recommended'],
  {
    rules: {
      ...prettierConfig.rules,
      'tailwindcss/no-custom-classname': 'off',
      'tailwindcss/classnames-order': 'off',
    },
  },
  {
    ignores: ['components/ui/**'],
  },
];

export default config;
