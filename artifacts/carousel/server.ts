import { streamObject } from 'ai';
import { z } from 'zod';
import { myProvider } from '@/lib/ai/providers';
import { carouselPrompt, updateCarouselPrompt } from '@/lib/ai/prompts';
import { createDocumentHandler } from '@/lib/artifacts/server';

const slideSchema = z.object({
  id: z.string(),
  backgroundImage: z.string().optional(),
  backgroundColor: z.string(),
  overlayOpacity: z.number(),
  content: z.discriminatedUnion('type', [
    z.object({
      type: z.literal('cover'),
      headline: z.string(),
      tagline: z.string().optional(),
    }),
    z.object({
      type: z.literal('stat'),
      number: z.string(),
      description: z.string(),
    }),
    z.object({
      type: z.literal('text'),
      title: z.string().optional(),
      body: z.string(),
    }),
    z.object({
      type: z.literal('outro'),
      message: z.string(),
      cta: z.string().optional(),
    }),
  ]),
});

const carouselSchema = z.object({
  theme: z.object({
    accentColor: z.string(),
    backgroundColor: z.string(),
    fontFamily: z.string(),
  }),
  brandName: z.string().optional(),
  logoUrl: z.string().optional(),
  slides: z.array(slideSchema),
});

export const carouselDocumentHandler = createDocumentHandler<'carousel'>({
  kind: 'carousel',
  onCreateDocument: async ({ title, dataStream }) => {
    let draftContent = '';

    const { fullStream } = streamObject({
      model: myProvider.languageModel('artifact-model'),
      system: carouselPrompt,
      prompt: title,
      schema: carouselSchema,
    });

    for await (const delta of fullStream) {
      if (delta.type === 'object') {
        const json = JSON.stringify(delta.object, null, 2);
        dataStream.write({
          type: 'data-carouselDelta',
          data: json,
          transient: true,
        });
        draftContent = json;
      }
    }

    return draftContent;
  },
  onUpdateDocument: async ({ document, description, dataStream }) => {
    let draftContent = '';

    const { fullStream } = streamObject({
      model: myProvider.languageModel('artifact-model'),
      system: updateCarouselPrompt(document.content),
      prompt: description,
      schema: carouselSchema,
    });

    for await (const delta of fullStream) {
      if (delta.type === 'object') {
        const json = JSON.stringify(delta.object, null, 2);
        dataStream.write({
          type: 'data-carouselDelta',
          data: json,
          transient: true,
        });
        draftContent = json;
      }
    }

    return draftContent;
  },
});
