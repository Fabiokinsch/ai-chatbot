'use client';

import { Artifact } from '@/components/create-artifact';
import {
  CopyIcon,
  RedoIcon,
  UndoIcon,
} from '@/components/icons';
import { toast } from 'sonner';
import { useState, useCallback } from 'react';

// ─── Types ────────────────────────────────────────────────────────────────────

type SlideContent =
  | { type: 'cover'; headline: string; tagline?: string }
  | { type: 'stat'; number: string; description: string }
  | { type: 'text'; title?: string; body: string }
  | { type: 'outro'; message: string; cta?: string };

interface Slide {
  id: string;
  backgroundImage?: string;
  backgroundColor: string;
  overlayOpacity: number;
  content: SlideContent;
}

interface CarouselTheme {
  accentColor: string;
  backgroundColor: string;
  fontFamily: string;
}

interface CarouselData {
  theme: CarouselTheme;
  brandName?: string;
  logoUrl?: string;
  slides: Slide[];
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function parseCarousel(raw: string): CarouselData | null {
  try {
    return JSON.parse(raw) as CarouselData;
  } catch {
    return null;
  }
}

// ─── Slide Renderer ───────────────────────────────────────────────────────────

function SlidePreview({
  slide,
  theme,
  brandName,
  logoUrl,
}: {
  slide: Slide;
  theme: CarouselTheme;
  brandName?: string;
  logoUrl?: string;
}) {
  const bg = slide.backgroundColor || theme.backgroundColor || '#000';
  const accent = theme.accentColor || '#84cc16';
  const font = theme.fontFamily || 'Montserrat, sans-serif';
  const overlay = `rgba(0,0,0,${slide.overlayOpacity ?? 0.6})`;

  return (
    <div
      style={{
        width: '100%',
        paddingBottom: '125%', // 1080:1350 ratio
        position: 'relative',
        backgroundColor: bg,
        fontFamily: font,
        overflow: 'hidden',
        borderRadius: '8px',
      }}
    >
      {/* Background image */}
      {slide.backgroundImage && (
        <img
          src={slide.backgroundImage}
          alt=""
          style={{
            position: 'absolute',
            inset: 0,
            width: '100%',
            height: '100%',
            objectFit: 'cover',
            opacity: 1 - (slide.overlayOpacity ?? 0.6),
          }}
        />
      )}

      {/* Gradient overlay */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: `linear-gradient(to bottom, rgba(0,0,0,0.4) 0%, ${overlay} 100%)`,
        }}
      />

      {/* Content */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
          padding: '8%',
          textAlign: 'center',
          color: '#fff',
          gap: '4%',
        }}
      >
        {slide.content.type === 'cover' && (
          <>
            <span
              style={{
                fontSize: 'clamp(1.4rem, 5vw, 3rem)',
                fontWeight: 900,
                color: accent,
                lineHeight: 1.1,
                textTransform: 'uppercase',
              }}
            >
              {slide.content.headline}
            </span>
            {slide.content.tagline && (
              <p
                style={{
                  fontSize: 'clamp(0.75rem, 2.5vw, 1.4rem)',
                  fontWeight: 400,
                  color: '#e2e8f0',
                  margin: 0,
                }}
              >
                {slide.content.tagline}
              </p>
            )}
          </>
        )}

        {slide.content.type === 'stat' && (
          <>
            <span
              style={{
                fontSize: 'clamp(1.6rem, 6vw, 3.5rem)',
                fontWeight: 900,
                color: accent,
                lineHeight: 1,
                textTransform: 'uppercase',
              }}
            >
              {slide.content.number}
            </span>
            <p
              style={{
                fontSize: 'clamp(0.75rem, 2.5vw, 1.3rem)',
                fontWeight: 400,
                color: '#e2e8f0',
                margin: 0,
                lineHeight: 1.4,
              }}
            >
              {slide.content.description}
            </p>
          </>
        )}

        {slide.content.type === 'text' && (
          <>
            {slide.content.title && (
              <span
                style={{
                  fontSize: 'clamp(1rem, 3.5vw, 2rem)',
                  fontWeight: 700,
                  color: accent,
                  lineHeight: 1.1,
                }}
              >
                {slide.content.title}
              </span>
            )}
            <p
              style={{
                fontSize: 'clamp(0.7rem, 2.2vw, 1.2rem)',
                color: '#e2e8f0',
                margin: 0,
                lineHeight: 1.5,
              }}
            >
              {slide.content.body}
            </p>
          </>
        )}

        {slide.content.type === 'outro' && (
          <>
            <p
              style={{
                fontSize: 'clamp(0.8rem, 2.8vw, 1.5rem)',
                fontWeight: 700,
                color: '#fff',
                margin: 0,
                lineHeight: 1.4,
                letterSpacing: '0.05em',
                textTransform: 'uppercase',
              }}
            >
              {slide.content.message}
            </p>
            {slide.content.cta && (
              <span
                style={{
                  fontSize: 'clamp(0.65rem, 2vw, 1.1rem)',
                  color: accent,
                  fontWeight: 600,
                }}
              >
                {slide.content.cta}
              </span>
            )}
          </>
        )}
      </div>

      {/* Brand footer */}
      {(brandName || logoUrl) && (
        <div
          style={{
            position: 'absolute',
            bottom: '4%',
            left: 0,
            right: 0,
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            padding: '0 8%',
          }}
        >
          {logoUrl ? (
            <img
              src={logoUrl}
              alt={brandName ?? 'logo'}
              style={{ maxHeight: '10%', maxWidth: '40%', objectFit: 'contain' }}
            />
          ) : (
            <span
              style={{
                color: '#fff',
                fontSize: 'clamp(0.6rem, 1.8vw, 0.9rem)',
                fontWeight: 700,
                opacity: 0.8,
                letterSpacing: '0.1em',
                textTransform: 'uppercase',
              }}
            >
              {brandName}
            </span>
          )}
        </div>
      )}
    </div>
  );
}

// ─── Edit Panel ───────────────────────────────────────────────────────────────

function EditableField({
  label,
  value,
  onChange,
  multiline = false,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  multiline?: boolean;
}) {
  return (
    <div className="flex flex-col gap-1">
      <label className="text-xs font-semibold text-zinc-400 uppercase tracking-wide">
        {label}
      </label>
      {multiline ? (
        <textarea
          className="rounded-md border border-zinc-700 bg-zinc-900 px-3 py-2 text-sm text-zinc-100 resize-y focus:outline-none focus:ring-1 focus:ring-zinc-500"
          rows={3}
          value={value}
          onChange={(e) => onChange(e.target.value)}
        />
      ) : (
        <input
          className="rounded-md border border-zinc-700 bg-zinc-900 px-3 py-2 text-sm text-zinc-100 focus:outline-none focus:ring-1 focus:ring-zinc-500"
          value={value}
          onChange={(e) => onChange(e.target.value)}
        />
      )}
    </div>
  );
}

function SlideEditor({
  slide,
  onChange,
}: {
  slide: Slide;
  onChange: (updated: Slide) => void;
}) {
  const c = slide.content;

  const setField = (key: string, value: string) => {
    onChange({ ...slide, content: { ...c, [key]: value } as SlideContent });
  };

  return (
    <div className="flex flex-col gap-4">
      <EditableField
        label="Imagem de fundo (URL)"
        value={slide.backgroundImage ?? ''}
        onChange={(v) => onChange({ ...slide, backgroundImage: v || undefined })}
      />
      <EditableField
        label="Opacidade do overlay (0–1)"
        value={String(slide.overlayOpacity)}
        onChange={(v) =>
          onChange({ ...slide, overlayOpacity: parseFloat(v) || 0.6 })
        }
      />

      {c.type === 'cover' && (
        <>
          <EditableField
            label="Título principal"
            value={c.headline}
            onChange={(v) => setField('headline', v)}
          />
          <EditableField
            label="Subtítulo"
            value={c.tagline ?? ''}
            onChange={(v) => setField('tagline', v)}
          />
        </>
      )}

      {c.type === 'stat' && (
        <>
          <EditableField
            label="Número / destaque"
            value={c.number}
            onChange={(v) => setField('number', v)}
          />
          <EditableField
            label="Descrição"
            value={c.description}
            onChange={(v) => setField('description', v)}
            multiline
          />
        </>
      )}

      {c.type === 'text' && (
        <>
          <EditableField
            label="Título"
            value={c.title ?? ''}
            onChange={(v) => setField('title', v)}
          />
          <EditableField
            label="Corpo do texto"
            value={c.body}
            onChange={(v) => setField('body', v)}
            multiline
          />
        </>
      )}

      {c.type === 'outro' && (
        <>
          <EditableField
            label="Mensagem"
            value={c.message}
            onChange={(v) => setField('message', v)}
            multiline
          />
          <EditableField
            label="Call to action"
            value={c.cta ?? ''}
            onChange={(v) => setField('cta', v)}
          />
        </>
      )}
    </div>
  );
}

// ─── Main Carousel Editor ─────────────────────────────────────────────────────

function CarouselEditor({
  content,
  onSaveContent,
  status,
}: {
  content: string;
  onSaveContent: (c: string, debounce: boolean) => void;
  status: 'streaming' | 'idle';
}) {
  const [activeIndex, setActiveIndex] = useState(0);

  const data = parseCarousel(content);

  const updateData = useCallback(
    (updated: CarouselData) => {
      onSaveContent(JSON.stringify(updated, null, 2), true);
    },
    [onSaveContent],
  );

  if (!data || !data.slides?.length) {
    return (
      <div className="flex items-center justify-center h-full text-zinc-400 text-sm">
        {status === 'streaming'
          ? 'Gerando carrossel…'
          : 'Nenhum conteúdo ainda.'}
      </div>
    );
  }

  const slide = data.slides[Math.min(activeIndex, data.slides.length - 1)];
  const safeIndex = Math.min(activeIndex, data.slides.length - 1);

  const updateSlide = (updated: Slide) => {
    const slides = [...data.slides];
    slides[safeIndex] = updated;
    updateData({ ...data, slides });
  };

  const updateTheme = (key: keyof CarouselTheme, value: string) => {
    updateData({ ...data, theme: { ...data.theme, [key]: value } });
  };

  const addSlide = () => {
    const newSlide: Slide = {
      id: `slide-${Date.now()}`,
      backgroundColor: data.theme.backgroundColor,
      overlayOpacity: 0.6,
      content: { type: 'stat', number: '0', description: 'Nova estatística' },
    };
    updateData({ ...data, slides: [...data.slides, newSlide] });
    setActiveIndex(data.slides.length);
  };

  const removeSlide = () => {
    if (data.slides.length <= 1) return;
    const slides = data.slides.filter((_, i) => i !== safeIndex);
    updateData({ ...data, slides });
    setActiveIndex(Math.max(0, safeIndex - 1));
  };

  return (
    <div className="flex flex-col lg:flex-row gap-4 h-full p-4 overflow-auto">
      {/* Left: Preview + navigation */}
      <div className="flex flex-col gap-3 lg:w-1/2">
        {/* Slide counter */}
        <div className="flex items-center justify-between">
          <span className="text-xs text-zinc-400 font-medium">
            Slide {safeIndex + 1} / {data.slides.length}
          </span>
          <span className="text-xs text-zinc-500 capitalize bg-zinc-800 px-2 py-0.5 rounded">
            {slide.content.type}
          </span>
        </div>

        {/* Preview */}
        <div className="w-full max-w-sm mx-auto">
          <SlidePreview
            slide={slide}
            theme={data.theme}
            brandName={data.brandName}
            logoUrl={data.logoUrl}
          />
        </div>

        {/* Dot navigation */}
        <div className="flex justify-center gap-2 flex-wrap mt-1">
          {data.slides.map((_, i) => (
            <button
              key={i}
              type="button"
              onClick={() => setActiveIndex(i)}
              className={`w-2 h-2 rounded-full transition-colors ${
                i === safeIndex ? 'bg-zinc-100' : 'bg-zinc-600 hover:bg-zinc-400'
              }`}
            />
          ))}
        </div>

        {/* Slide strip thumbnails */}
        <div className="flex gap-2 overflow-x-auto py-1">
          {data.slides.map((s, i) => (
            <button
              key={s.id}
              type="button"
              onClick={() => setActiveIndex(i)}
              className={`flex-shrink-0 w-14 aspect-[4/5] rounded overflow-hidden border-2 transition-colors ${
                i === safeIndex
                  ? 'border-zinc-200'
                  : 'border-zinc-700 hover:border-zinc-500'
              }`}
              style={{ backgroundColor: s.backgroundColor || '#000' }}
            >
              <SlidePreview
                slide={s}
                theme={data.theme}
                brandName={data.brandName}
                logoUrl={data.logoUrl}
              />
            </button>
          ))}
          <button
            type="button"
            onClick={addSlide}
            className="flex-shrink-0 w-14 aspect-[4/5] rounded border-2 border-dashed border-zinc-600 hover:border-zinc-400 flex items-center justify-center text-zinc-400 hover:text-zinc-200 text-xl transition-colors"
          >
            +
          </button>
        </div>
      </div>

      {/* Right: Editors */}
      <div className="flex flex-col gap-5 lg:w-1/2 lg:overflow-y-auto">
        {/* Theme */}
        <div className="rounded-lg border border-zinc-700 bg-zinc-900/50 p-4 flex flex-col gap-3">
          <h3 className="text-xs font-bold text-zinc-300 uppercase tracking-widest">
            Tema global
          </h3>
          <div className="flex gap-3 flex-wrap">
            <div className="flex flex-col gap-1">
              <label className="text-xs text-zinc-400 uppercase tracking-wide font-semibold">
                Cor de destaque
              </label>
              <div className="flex items-center gap-2">
                <input
                  type="color"
                  value={data.theme.accentColor}
                  onChange={(e) => updateTheme('accentColor', e.target.value)}
                  className="w-8 h-8 rounded cursor-pointer border border-zinc-600"
                />
                <span className="text-xs text-zinc-400 font-mono">
                  {data.theme.accentColor}
                </span>
              </div>
            </div>
            <div className="flex flex-col gap-1">
              <label className="text-xs text-zinc-400 uppercase tracking-wide font-semibold">
                Cor de fundo
              </label>
              <div className="flex items-center gap-2">
                <input
                  type="color"
                  value={data.theme.backgroundColor}
                  onChange={(e) =>
                    updateTheme('backgroundColor', e.target.value)
                  }
                  className="w-8 h-8 rounded cursor-pointer border border-zinc-600"
                />
                <span className="text-xs text-zinc-400 font-mono">
                  {data.theme.backgroundColor}
                </span>
              </div>
            </div>
          </div>
          <EditableField
            label="Nome da marca"
            value={data.brandName ?? ''}
            onChange={(v) => updateData({ ...data, brandName: v || undefined })}
          />
          <EditableField
            label="URL do logo"
            value={data.logoUrl ?? ''}
            onChange={(v) => updateData({ ...data, logoUrl: v || undefined })}
          />
        </div>

        {/* Slide editor */}
        <div className="rounded-lg border border-zinc-700 bg-zinc-900/50 p-4 flex flex-col gap-4">
          <div className="flex items-center justify-between">
            <h3 className="text-xs font-bold text-zinc-300 uppercase tracking-widest">
              Slide {safeIndex + 1}
            </h3>
            <button
              type="button"
              onClick={removeSlide}
              disabled={data.slides.length <= 1}
              className="text-xs text-red-400 hover:text-red-300 disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
            >
              Remover slide
            </button>
          </div>
          <SlideEditor slide={slide} onChange={updateSlide} />
        </div>
      </div>
    </div>
  );
}

// ─── Export HTML ──────────────────────────────────────────────────────────────

function exportHTML(data: CarouselData): string {
  const slidesHtml = data.slides
    .map((slide) => {
      const c = slide.content;
      const accent = data.theme.accentColor;
      const bg = slide.backgroundColor || data.theme.backgroundColor || '#000';
      const overlayColor = `rgba(0,0,0,${slide.overlayOpacity ?? 0.6})`;

      let innerHtml = '';
      if (c.type === 'cover') {
        innerHtml = `
          <span class="big-number">${c.headline}</span>
          ${c.tagline ? `<p class="data-desc">${c.tagline}</p>` : ''}
        `;
      } else if (c.type === 'stat') {
        innerHtml = `
          <span class="big-number">${c.number}</span>
          <p class="data-desc">${c.description}</p>
        `;
      } else if (c.type === 'text') {
        innerHtml = `
          ${c.title ? `<span class="big-number" style="font-size:60px">${c.title}</span>` : ''}
          <p class="data-desc">${c.body}</p>
        `;
      } else if (c.type === 'outro') {
        innerHtml = `
          <p class="date-line">${c.message}</p>
          ${c.cta ? `<span class="big-number" style="font-size:40px">${c.cta}</span>` : ''}
        `;
      }

      const brandFooter =
        data.brandName || data.logoUrl
          ? `<div class="logo-container">${
              data.logoUrl
                ? `<img src="${data.logoUrl}" class="logo" alt="${data.brandName ?? ''}">`
                : `<span class="brand-name">${data.brandName}</span>`
            }</div>`
          : '';

      return `
  <div class="slide-container" style="background:${bg}">
    ${slide.backgroundImage ? `<img src="${slide.backgroundImage}" class="background-image">` : ''}
    <div class="overlay-gradient" style="background:linear-gradient(to bottom,rgba(0,0,0,0.4) 0%,${overlayColor} 100%)"></div>
    <div class="content">
      ${innerHtml}
    </div>
    ${brandFooter}
  </div>`;
    })
    .join('\n');

  return `<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>${data.brandName ?? 'Carrossel Instagram'}</title>
  <link href="https://fonts.googleapis.com/css2?family=${encodeURIComponent(data.theme.fontFamily || 'Montserrat')}:wght@400;700;900&display=swap" rel="stylesheet">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { background: #111; display: flex; flex-direction: column; align-items: center; gap: 24px; padding: 40px 20px; font-family: '${data.theme.fontFamily || 'Montserrat'}', sans-serif; }
    .slide-container { width: 1080px; height: 1350px; position: relative; color: #fff; overflow: hidden; display: flex; flex-direction: column; justify-content: center; align-items: center; }
    .background-image { position: absolute; inset: 0; width: 1080px; height: 1350px; object-fit: cover; opacity: 0.35; }
    .overlay-gradient { position: absolute; inset: 0; }
    .content { position: relative; z-index: 10; text-align: center; padding: 0 80px; display: flex; flex-direction: column; align-items: center; gap: 60px; }
    .big-number { font-size: 100px; font-weight: 900; color: ${data.theme.accentColor}; line-height: 1; display: block; text-transform: uppercase; }
    .data-desc { font-size: 36px; font-weight: 400; line-height: 1.3; color: #e2e8f0; margin-top: 15px; }
    .date-line { font-size: 40px; font-weight: 700; color: #fff; letter-spacing: 3px; text-transform: uppercase; }
    .logo-container { position: absolute; bottom: 80px; width: 100%; display: flex; justify-content: center; z-index: 20; }
    .logo { height: 120px; object-fit: contain; }
    .brand-name { color: #fff; font-size: 28px; font-weight: 700; letter-spacing: 0.1em; text-transform: uppercase; opacity: 0.85; }
  </style>
</head>
<body>
${slidesHtml}
</body>
</html>`;
}

// ─── Artifact Definition ──────────────────────────────────────────────────────

export const carouselArtifact = new Artifact<'carousel'>({
  kind: 'carousel',
  description:
    'Gerador de carrossel editável para Instagram (formato 4:5, 1080×1350px). Ideal para posts com estatísticas, dados e mensagens de impacto.',

  onStreamPart: ({ streamPart, setArtifact }) => {
    if (streamPart.type === 'data-carouselDelta') {
      setArtifact((draft) => ({
        ...draft,
        content: streamPart.data as string,
        isVisible: true,
        status: 'streaming',
      }));
    }
  },

  content: ({ content, onSaveContent, status }) => (
    <CarouselEditor
      content={content}
      onSaveContent={onSaveContent}
      status={status}
    />
  ),

  actions: [
    {
      icon: <UndoIcon size={18} />,
      description: 'Versão anterior',
      onClick: ({ handleVersionChange }) => handleVersionChange('prev'),
      isDisabled: ({ currentVersionIndex }) => currentVersionIndex === 0,
    },
    {
      icon: <RedoIcon size={18} />,
      description: 'Próxima versão',
      onClick: ({ handleVersionChange }) => handleVersionChange('next'),
      isDisabled: ({ isCurrentVersion }) => isCurrentVersion,
    },
    {
      icon: <CopyIcon size={18} />,
      description: 'Copiar JSON',
      onClick: ({ content }) => {
        navigator.clipboard.writeText(content);
        toast.success('JSON copiado!');
      },
    },
    {
      label: 'HTML',
      icon: (
        <svg
          width="18"
          height="18"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
          <polyline points="7 10 12 15 17 10" />
          <line x1="12" y1="15" x2="12" y2="3" />
        </svg>
      ),
      description: 'Exportar HTML',
      onClick: ({ content }) => {
        const data = parseCarousel(content);
        if (!data) {
          toast.error('Conteúdo inválido');
          return;
        }
        const html = exportHTML(data);
        const blob = new Blob([html], { type: 'text/html' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'carousel-instagram.html';
        a.click();
        URL.revokeObjectURL(url);
        toast.success('HTML exportado!');
      },
    },
  ],

  toolbar: [],
});
