#ifndef UIEFFECT_H
#define UIEFFECT_H

#include "effect.h"
#include <framework/ui/uiwidget.h>

class UIEffect : public UIWidget
{
public:
    void drawSelf(Fw::DrawPane drawPane) override;

    void setEffect(const EffectPtr& effect);
    EffectPtr getEffect() { return m_effect; }

    void setScale(float scale) { m_scale = scale; }
    float getScale() { return m_scale; }

protected:
    void onStyleApply(const std::string& styleName, const OTMLNodePtr& styleNode) override;
    void onGeometryChange(const Rect& oldRect, const Rect& newRect) override;

private:
    EffectPtr m_effect;
    float m_scale = 1.0;
};

#endif
